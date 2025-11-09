// widgets/experience_card.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// A compact, visually engaging card used to display experience/hobby/interest images
/// in a grid or horizontal list (e.g., during onboarding or profile setup).
///
/// Features:
/// • 80×80 fixed size with subtle random rotation for organic, "polaroid" feel
/// • Smooth selection animation (color → grayscale + overlay removal)
/// • Cached network image loading with placeholder & error handling
/// • Deep shadow for depth
/// • Dark bottom gradient overlay when not selected
/// • Tap feedback via `onTap` callback
///
/// Visual States:
/// - Selected: Full color, no overlay, no grayscale
/// - Unselected: Grayscale filter + dark gradient overlay
///
/// The slight random rotation prevents the grid from looking too rigid and robotic.
class ExperienceCard extends StatelessWidget {
  /// URL of the image to display (typically from a predefined experience list).
  final String imageUrl;

  /// Whether this card is currently selected by the user.
  final bool isSelected;

  /// Callback triggered when the user taps the card.
  final VoidCallback onTap;

  const ExperienceCard({
    super.key,
    required this.imageUrl,
    required this.isSelected,
    required this.onTap,
  });

  /// Generates a small random rotation angle based on the image URL hash.
  /// 
  /// Why hash the URL?
  /// - Ensures the same image always has the same rotation (stable layout)
  /// - No need for external random seed or state
  /// 
  /// Range: approximately -4° to +4° (converted to radians)
  /// This creates a playful, scattered look without breaking alignment.
  double get _rotationAngle {
    final hash = imageUrl.hashCode.abs();
    final angleDegrees = (hash % 9 - 4) * 1.0; // -4 to +4
    return angleDegrees * (3.14159 / 180); // degrees → radians
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Handle selection toggle
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic, // Smooth, natural deceleration
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          // Transparent border (kept for potential future use)
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.transparent,
            width: 2.5,
          ),
          // Deep shadow to make cards "float" above the background
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge, // Ensures rotated content doesn't overflow
        child: Stack(
          children: [
            // Rotated inner content (image + filters)
            Transform.rotate(
              angle: _rotationAngle,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Main image with grayscale filter when not selected
                  ColorFiltered(
                    // When selected: no filter (full color)
                    // When unselected: apply grayscale matrix
                    colorFilter: isSelected
                        ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
                        : const ColorFilter.matrix(<double>[
                            // Standard luminance grayscale coefficients
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0,      0,      0,      1, 0,
                          ]),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      // Dark gray placeholder during loading
                      placeholder: (_, __) => Container(color: Colors.grey[800]),
                      // Same color on error (prevents broken image icon)
                      errorWidget: (_, __, ___) => Container(color: Colors.grey[800]),
                    ),
                  ),

                  // Dark gradient overlay – only visible when NOT selected
                  // Creates a "dimmed" effect that lifts on selection
                  if (!isSelected)
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.75), // Strong at bottom
                            Colors.transparent,            // Fades to top
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}