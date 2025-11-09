// screens/onboarding_question_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vamsi_assignment/utils/wavy_progress_painter.dart';
import 'package:vamsi_assignment/widgets/description_textfield1.dart'; // Adjust import if needed
import 'package:vamsi_assignment/widgets/audio_video_recorder.dart';

/// Onboarding Step 02/04 – "Why do you want to host with us?"
///
/// Users answer a motivational question by:
/// • Writing a text description (required)
/// • Optionally recording audio or video to support their intent
/// Navigation:
/// • Back button → previous step
class OnboardingQuestionScreen extends StatefulWidget {
  const OnboardingQuestionScreen({super.key});

  @override
  State<OnboardingQuestionScreen> createState() => _OnboardingQuestionScreenState();
}

class _OnboardingQuestionScreenState extends State<OnboardingQuestionScreen> {
  /// Controller for the description text field (required input).
  final TextEditingController _descController = TextEditingController();

  /// Paths to recorded audio/video files (optional).
  String? _audioPath;
  String? _videoPath;

  /// Determines if the "Next" button should be enabled.
  /// Requires non-empty trimmed text description.
  bool get _canProceed => _descController.text.trim().isNotEmpty;

  /// Callback triggered when audio/video recording is completed or cancelled.
  /// Updates local state with file paths.
  void _onRecorded(String? audio, String? video) {
    setState(() {
      _audioPath = audio;
      _videoPath = video;
    });
  }

  @override
  void dispose() {
    // Clean up controller to prevent memory leaks
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// True if user has recorded either audio or video.
    final hasRecording = _audioPath != null || _videoPath != null;

    return Scaffold(
      resizeToAvoidBottomInset: true, // Adjusts layout when keyboard appears
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          color: const Color.fromRGBO(255, 255, 255, 0.02),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  // Back navigation
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                    onPressed: () => Navigator.maybePop(context),
                    padding: EdgeInsets.zero,
                  ),
                  // Progress indicator – 70% complete (step 2 of ~4)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        height: 6,
                        child: WavyProgressBar(
                          progress: 0.7,
                          activeColor: const Color(0xFF9196FF),
                          inactiveColor: const Color(0xFF4A4A4A),
                        ),
                      ),
                    ),
                  ),
                  // Exit onboarding entirely
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 24),
                    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Scrollable content area
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 180), // Visual breathing room at top
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Step number
                        Text(
                          '02',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Main question
                        Text(
                          'Why do you want to host with us?',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Supporting text
                        Text(
                          'Tell us about your intent and what motivates you to create experiences.',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Text input field
                  DescriptionTextField(controller: _descController),
                  const SizedBox(height: 10),
                  // Audio/Video recorder row (with playback, cancel, next logic)
                  AudioVideoRecorderRow(
                    onRecorded: _onRecorded,
                    hasRecording: hasRecording,
                    nextEnabled: _canProceed,
                    onNext: () {
                      // Final submission point
                      debugPrint("Description: ${_descController.text}");
                      debugPrint("Audio path: $_audioPath");
                      debugPrint("Video path: $_videoPath");

                      // TODO: Upload data to backend or proceed to next screen
                      // Navigator.push(context, MaterialPageRoute(...));
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}