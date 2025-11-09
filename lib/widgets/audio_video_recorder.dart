// widgets/audio_video_recorder_row.dart
import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vamsi_assignment/widgets/next_button.dart';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'dart:io';

/// A combined audio + video recorder widget displayed as a bottom row.
/// 
/// Features:
/// • Record audio with live waveform
/// • Record video using full-screen camera
/// • Play back recorded audio/video
/// • Cancel recording
/// • Show recording duration
/// • Gradient styling when recording or a file exists
/// • Proper permission handling with system settings fallback
/// • Lifecycle-aware camera handling (re-initialize on resume)
///
/// Callbacks:
/// • `onRecorded(String? audioPath, String? videoPath)` – called when recording stops
/// • `onNext()` – forwarded to the NextButton
/// • `hasRecording` – external flag to control UI (e.g., from parent)
/// • `nextEnabled` – controls NextButton state
class AudioVideoRecorderRow extends StatefulWidget {
  final Function(String?, String?) onRecorded;
  final bool hasRecording;
  final bool nextEnabled;
  final VoidCallback onNext;

  const AudioVideoRecorderRow({
    super.key,
    required this.onRecorded,
    required this.hasRecording,
    required this.nextEnabled,
    required this.onNext,
  });

  @override
  State<AudioVideoRecorderRow> createState() => _AudioVideoRecorderRowState();
}

class _AudioVideoRecorderRowState extends State<AudioVideoRecorderRow>
    with WidgetsBindingObserver {
  // Controllers for audio recording & playback
  late RecorderController _recorderController;
  late PlayerController _playerController;

  // Camera & video playback controllers
  CameraController? _cameraController;
  VideoPlayerController? _videoPlayerController;

  // Recording state flags
  bool _isRecordingAudio = false;
  bool _isPlaying = false;
  Duration _recordingDuration = Duration.zero;
  Timer? _timer;

  // Paths to the final recorded files
  String? _recordedAudioPath;
  String? _recordedVideoPath;

  /// True when either an audio or video file has been successfully recorded.
  bool get _hasFinalRecording => _recordedAudioPath != null || _recordedVideoPath != null;

  @override
  void initState() {
    super.initState();
    // Observe app lifecycle to properly dispose/re-initialize camera
    WidgetsBinding.instance.addObserver(this);

    // Initialise audio recorder with high-quality settings
    _recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;

    // Initialise audio player (used for playback of recorded audio)
    _playerController = PlayerController();
  }

  /// Initialise the back camera (or first available) with high resolution.
  /// Called on first use and when the app resumes from background.
  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      // Prefer back camera, fallback to any available camera
      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras[0],
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: true, // needed for video recording with sound
      );

      await _cameraController!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("CAMERA ERROR: $e");
    }
  }

  /// Handle app lifecycle changes – especially important for camera resource management.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      // App is going to background or being terminated
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // App came back to foreground – re-initialize camera
      _initializeCamera();
    }
  }

  /// Start a periodic timer that increments the displayed recording duration.
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _recordingDuration += const Duration(seconds: 1));
      }
    });
  }

  /// Stop and cancel the duration timer.
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    // Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(this);

    // Clean up timers and controllers
    _stopTimer();
    _recorderController.dispose();
    _playerController.dispose();
    _cameraController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  /// Request microphone permission and start recording if granted.
  Future<void> _requestMicPermission() async {
    var status = await Permission.microphone.status;
    if (status.isDenied) {
      status = await Permission.microphone.request();
    }

    if (status.isPermanentlyDenied) {
      _showPermissionDialog("Microphone");
      return;
    }

    if (status.isGranted) {
      await _recorderController.record();
      setState(() {
        _isRecordingAudio = true;
        _recordingDuration = Duration.zero;
      });
      _startTimer();
    }
  }

  /// Toggle audio recording: start → stop or stop → start.
  void _toggleAudio() async {
    if (_isRecordingAudio) {
      // Stop recording
      final path = await _recorderController.stop();
      _stopTimer();
      setState(() {
        _isRecordingAudio = false;
        _recordedAudioPath = path;
      });
      widget.onRecorded(path, _recordedVideoPath);
    } else {
      // Start recording
      await _requestMicPermission();
    }
  }

  /// Open full-screen camera screen for video recording.
  /// Handles both camera and microphone permissions.
  Future<void> _openFullCamera() async {
    final camGranted = await Permission.camera.request().isGranted;
    final micGranted = await Permission.microphone.request().isGranted;

    if (!camGranted || !micGranted) {
      _showPermissionDialog("Camera & Microphone");
      return;
    }

    await _initializeCamera();
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CameraRecordingScreen(
          controller: _cameraController!,
          onStop: (path) async {
            setState(() => _recordedVideoPath = path);

            // Initialise video player to obtain duration and thumbnail
            final videoController = VideoPlayerController.file(File(path));
            await videoController.initialize();

            setState(() {
              _recordingDuration = videoController.value.duration;
            });

            _videoPlayerController = videoController;
            widget.onRecorded(_recordedAudioPath, path);

            if (mounted) setState(() {});
          },
        ),
      ),
    );
  }

  /// Cancel current recording (audio or video) and reset UI.
  void _cancel() async {
    await _videoPlayerController?.dispose();
    _videoPlayerController = null;
    _playerController.stopPlayer();
    _stopTimer();

    setState(() {
      _isRecordingAudio = false;
      _isPlaying = false;
      _recordingDuration = Duration.zero;
      _recordedAudioPath = null;
      _recordedVideoPath = null;
    });

    widget.onRecorded(null, null);
  }

  /// Play/pause the recorded audio or open full-screen video player.
  Future<void> _playPauseRecording() async {
    // Video playback → open full-screen player
    if (_recordedVideoPath != null && _videoPlayerController != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FullScreenVideoPlayer(controller: _videoPlayerController!),
        ),
      );
      return;
    }

    // Audio playback
    if (_recordedAudioPath != null) {
      if (_isPlaying) {
        await _playerController.pausePlayer();
      } else {
        if (_playerController.playerState == PlayerState.stopped) {
          await _playerController.preparePlayer(path: _recordedAudioPath!);
        }
        await _playerController.startPlayer();
      }
      setState(() => _isPlaying = !_isPlaying);
    }
  }

  /// Format Duration → MM:SS
  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Show a dialog explaining that permission is required and offer to open settings.
  void _showPermissionDialog(String permission) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text("$permission Required", style: const TextStyle(color: Colors.white)),
        content: Text("Please allow $permission access.", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () => openAppSettings().then((_) => Navigator.pop(context)),
            child: const Text("Open Settings", style: TextStyle(color: Color(0xFF9196FF))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // UI visibility logic
    final bool showRecorded = widget.hasRecording && !_isRecordingAudio;
    final bool isVideoMode = _recordedVideoPath != null;
    final bool showGradient = _isRecordingAudio || _hasFinalRecording;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // ==================== RECORDED MEDIA PREVIEW ====================
          if (_isRecordingAudio || showRecorded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---- LIVE AUDIO RECORDING UI ----
                  if (_isRecordingAudio) ...[
                    const Text("Audio Recording", style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // Recording indicator (purple check)
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(color: Color(0xFF9196FF), shape: BoxShape.circle),
                          child: const Icon(Icons.check, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 16),
                        // Live waveform
                        Expanded(
                          child: AudioWaveforms(
                            recorderController: _recorderController,
                            waveStyle: const WaveStyle(waveColor: Colors.white, spacing: 6),
                            size: const Size(double.infinity, 50),
                            enableGesture: false,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Duration counter
                        Text(
                          _formatDuration(_recordingDuration),
                          style: const TextStyle(color: Color(0xFF9196FF), fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ]
                  // ---- AUDIO PLAYBACK UI ----
                  else if (!isVideoMode && _recordedAudioPath != null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Audio Recorded • ${_formatDuration(_recordingDuration)}",
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ),
                        GestureDetector(
                          onTap: _cancel,
                          child: const Icon(Icons.delete_outline, color: Color(0xFF9196FF), size: 24),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // Play/Pause button
                        GestureDetector(
                          onTap: _playPauseRecording,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(color: Color(0xFF6C5CE7), shape: BoxShape.circle),
                            child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Static waveform of recorded file
                        Expanded(
                          child: AudioFileWaveforms(
                            size: const Size(double.infinity, 50),
                            playerController: _playerController,
                            enableSeekGesture: false,
                            playerWaveStyle: const PlayerWaveStyle(
                              fixedWaveColor: Colors.white24,
                              liveWaveColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]
                  // ---- VIDEO THUMBNAIL UI ----
                  else if (isVideoMode && _videoPlayerController?.value.isInitialized == true)
                    Row(
                      children: [
                        // Thumbnail with play overlay
                        GestureDetector(
                          onTap: _playPauseRecording,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Stack(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: FileImage(File(_recordedVideoPath!)),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.black.withOpacity(0.4),
                                  ),
                                  child: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Video Recorded • ${_formatDuration(_recordingDuration)}",
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: _cancel,
                          child: const Icon(Icons.delete_outline, color: Color(0xFF9196FF), size: 24),
                        ),
                      ],
                    ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // ==================== BOTTOM ACTION BAR ====================
          Row(
            children: [
              // Mic & Camera buttons (only when nothing is recorded)
              if (!_hasFinalRecording)
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    // Gradient when recording audio, solid otherwise
                    gradient: _isRecordingAudio
                        ? const LinearGradient(colors: [
                            Color(0xFF222222),
                            Color(0xFF323232),
                            Color(0xFF424242),
                            Color(0xFF424242),
                            Color(0xFF323232),
                            Color(0xFF222222)
                          ])
                        : null,
                    color: _isRecordingAudio ? null : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                  ),
                  child: Row(
                    children: [
                      // Microphone button (record/stop)
                      GestureDetector(
                        onTap: _toggleAudio,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            _isRecordingAudio ? Icons.stop : Icons.mic_none_outlined,
                            color: _isRecordingAudio ? Colors.red : Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      // Divider
                      Container(width: 1, height: 32, color: Colors.white24),
                      // Camera button
                      GestureDetector(
                        onTap: _openFullCamera,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: const Icon(Icons.videocam_outlined, color: Colors.white, size: 24),
                        ),
                      ),
                    ],
                  ),
                ),

              // Spacer when buttons are visible
              if (!_hasFinalRecording) const Spacer(),

              // Next button (expands when a recording exists)
              SizedBox(
                width: _hasFinalRecording ? 350 : 225,
                height: 56,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    gradient: showGradient
                        ? const LinearGradient(colors: [
                            Color(0xFF222222),
                            Color(0xFF323232),
                            Color(0xFF424242),
                            Color(0xFF424242),
                            Color(0xFF323232),
                            Color(0xFF222222)
                          ])
                        : null,
                    color: showGradient ? null : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                  ),
                  child: NextButton(onPressed: widget.onNext, isEnabled: widget.nextEnabled),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ========================= FULL-SCREEN CAMERA SCREEN =========================
class CameraRecordingScreen extends StatefulWidget {
  final CameraController controller;
  final Function(String) onStop;

  const CameraRecordingScreen({super.key, required this.controller, required this.onStop});

  @override
  State<CameraRecordingScreen> createState() => _CameraRecordingScreenState();
}

class _CameraRecordingScreenState extends State<CameraRecordingScreen> {
  late Future<void> _startFuture;

  @override
  void initState() {
    super.initState();
    // Start video recording as soon as the screen appears
    _startFuture = widget.controller.startVideoRecording();
  }

  /// Stop recording and return the file path to the parent widget.
  Future<void> _stopRecording() async {
    final xFile = await widget.controller.stopVideoRecording();
    if (mounted) {
      Navigator.pop(context);
      widget.onStop(xFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: _startFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return GestureDetector(
              onTap: _stopRecording,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CameraPreview(widget.controller),
                  const Center(child: Text("Tap to Stop", style: TextStyle(color: Colors.white70, fontSize: 18))),
                  Positioned(
                    top: 40,
                    left: 16,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context), // cancel without saving
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        },
      ),
    );
  }
}

// ========================= FULL-SCREEN VIDEO PLAYER =========================
class FullScreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;

  const FullScreenVideoPlayer({super.key, required this.controller});

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  @override
  void initState() {
    super.initState();
    // Auto-play when entering full-screen
    widget.controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AspectRatio(
          aspectRatio: widget.controller.value.aspectRatio,
          child: VideoPlayer(widget.controller),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black54,
        child: Icon(widget.controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
        onPressed: () => setState(() {
          widget.controller.value.isPlaying ? widget.controller.pause() : widget.controller.play();
        }),
      ),
    );
  }

  @override
  void dispose() {
    // Pause video when leaving the screen (prevents audio continuing in background)
    widget.controller.pause();
    super.dispose();
  }
}