// widgets/next_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A full-width "Next" button with a sleek gradient background, SVG arrow icon,
/// and proper enabled/disabled states.
///
/// Visual Design:
/// • Horizontal metallic gradient (dark gray → light → dark) when enabled
/// • Subtle border with reduced opacity when disabled
/// • High-contrast white text and icon
/// • Smooth disabled state (dimmed opacity, no gradient)
/// • Uses `Ink` + `ElevatedButton` for ripple effect without elevation shadow
///
/// Accessibility & UX:
/// • Fully disabled interaction when `isEnabled = false`
/// • Clear visual distinction between enabled/disabled
/// • Consistent height (56dp) and corner radius (8dp) matching design system
///
/// Used throughout onboarding and form flows.
class NextButton extends StatelessWidget {
  /// Callback triggered when the button is pressed.
  /// Ignored if `isEnabled` is false.
  final VoidCallback onPressed;

  /// Controls interactivity and visual state.
  /// `true` → gradient + full opacity
  /// `false` → dimmed, no gradient, disabled tap
  final bool isEnabled;

  const NextButton({
    super.key,
    required this.onPressed,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    // Reusable metallic gradient mimicking brushed metal / premium feel
    final gradient = const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color(0xFF222222), // Dark edge
        Color(0xFF323232),
        Color(0xFF424242), // Center highlight
        Color(0xFF424242),
        Color(0xFF323232),
        Color(0xFF222222), // Dark edge
      ],
    );

    return Padding(
      padding: EdgeInsets.zero, // Allows parent to control spacing
      child: SizedBox(
        width: double.infinity, // Full-width button
        height: 56,             // Standard touch target height
        child: Ink(
          // Ink provides Material ripple effect without background conflicts
          decoration: BoxDecoration(
            // Apply gradient only when enabled
            gradient: isEnabled ? gradient : null,
            // Fallback flat color when disabled
            color: isEnabled
                ? null
                : const Color.fromRGBO(255, 255, 255, 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isEnabled
                  ? Colors.white.withOpacity(0.12)  // Subtle border when active
                  : Colors.white.withOpacity(0.06), // Dimmed when disabled
              width: 1,
            ),
          ),
          child: ElevatedButton(
            // Null onPressed = fully disabled (no ripple, no tap)
            onPressed: isEnabled ? onPressed : null,
            style: ElevatedButton.styleFrom(
              // Transparent background to let Ink's decoration show through
              backgroundColor: Colors.transparent,
              // Remove default elevation shadow
              shadowColor: Colors.transparent,
              // Ripple color (subtle white)
              foregroundColor: Colors.white.withOpacity(0.16),
              // Disabled ripple color
              disabledBackgroundColor: Colors.transparent,
              disabledForegroundColor: Colors.white.withOpacity(0.08),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Button label
                Text(
                  'Next',
                  style: TextStyle(
                    color: isEnabled
                        ? Colors.white.withOpacity(0.9)
                        : Colors.white.withOpacity(0.3),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(width: 10),
                // Right arrow icon from SVG (scalable, clean)
                SvgPicture.asset(
                  'assets/Next.svg',
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    isEnabled
                        ? Colors.white.withOpacity(0.9)
                        : Colors.white.withOpacity(0.3),
                    BlendMode.srcIn, // Ensures clean tinting of SVG
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}