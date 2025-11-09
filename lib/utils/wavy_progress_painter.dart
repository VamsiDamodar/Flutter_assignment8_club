// utils/wavy_progress_painter.dart
import 'package:flutter/material.dart';

/// A visually engaging, animated wavy progress bar with two modes:
/// 
/// 1. Compact mode (default): thin horizontal progress indicator
/// 2. Full-screen background mode: subtle animated waves across the entire screen
///
/// Features:
/// • Smooth quadratic bezier wave pattern
/// • Configurable colors and height
/// • Progress animation (0.0 → 1.0)
/// • Full-screen mode draws faint background waves (ideal for onboarding backgrounds)
/// • High performance using `PathMetrics` for precise progress clipping
class WavyProgressBar extends StatelessWidget {
  /// Progress value between 0.0 and 1.0 (clamped automatically).
  final double progress;

  /// Color of the active (filled) portion of the wave.
  final Color activeColor;

  /// Color of the inactive (background) wave when not in full-screen mode.
  final Color inactiveColor;

  /// Height of the bar in compact mode. Ignored when `fullScreen = true`.
  final double height;

  /// When true, renders faint waves across the entire screen.
  /// Perfect for onboarding step backgrounds.
  final bool fullScreen;

  const WavyProgressBar({
    super.key,
    this.progress = 1.0,
    this.activeColor = const Color(0xFF9196FF),
    this.inactiveColor = const Color(0xFF4A4A4A),
    this.height = 20.0,
    this.fullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: fullScreen ? double.infinity : height,
      width: double.infinity,
      child: CustomPaint(
        painter: _WavyProgressPainter(
          progress: progress,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
          fullScreen: fullScreen,
        ),
      ),
    );
  }
}

/// Custom painter responsible for drawing the wavy line and clipping it based on progress.
class _WavyProgressPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color inactiveColor;
  final bool fullScreen;

  _WavyProgressPainter({
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
    required this.fullScreen,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Adjust wave amplitude and frequency based on mode
    final waveHeight = fullScreen ? size.height * 0.12 : size.height / 1.5;
    final waveLength = fullScreen ? size.width / 8 : size.width / 16;

    // Build the complete wave path (center-aligned vertically)
    final fullPath = Path();
    fullPath.moveTo(0, size.height / 2);

    double x = 0;
    bool isUp = true;

    // Generate repeating quadratic bezier curves to form a smooth wave
    while (x < size.width) {
      final cpX = x + waveLength / 2;
      final cpY = isUp
          ? size.height / 2 - waveHeight
          : size.height / 2 + waveHeight;
      final endX = x + waveLength;

      fullPath.quadraticBezierTo(cpX, cpY, endX, size.height / 2);

      x += waveLength;
      isUp = !isUp;
    }

    // Paint the full background wave
    final backgroundPaint = Paint()
      ..color = fullScreen
          ? Colors.grey.withOpacity(0.15)  // Subtle for full-screen background
          : inactiveColor
      ..strokeWidth = fullScreen ? 2.0 : 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(fullPath, backgroundPaint);

    // Only draw the active (colored) portion in compact mode
    if (!fullScreen && progress > 0) {
      final pathMetrics = fullPath.computeMetrics();
      final activePath = Path();

      // Extract exact portion of the path corresponding to progress
      for (final metric in pathMetrics) {
        final extractLength = (metric.length * progress).clamp(0.0, metric.length);
        activePath.addPath(metric.extractPath(0, extractLength), Offset.zero);
      }

      final activePaint = Paint()
        ..color = activeColor
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(activePath, activePaint);
    }
  }

  /// Always repaint when progress or size changes for smooth animation.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}