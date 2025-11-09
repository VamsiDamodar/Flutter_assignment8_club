// widgets/description_textfield.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A customizable, multiline text field designed for entering hotspot descriptions.
///
/// Features:
/// • 250-character limit
/// • Auto-expanding height (min 4 lines, grows as needed)
/// • Custom Space Grotesk typography
/// • Subtle dark theme styling with purple focus border
/// • Hint text with low opacity
/// • No visible character counter (hidden via `counterText: ''`)
/// • Clean, borderless look when unfocused
///
/// Usage:
/// ```dart
/// DescriptionTextField(controller: _descriptionController)
/// ```
class DescriptionTextField extends StatefulWidget {
  /// Controller to manage the text input and retrieve the entered description.
  final TextEditingController controller;

  /// Maximum allowed characters (fixed at 250).
  final int charLimit = 250;

  const DescriptionTextField({
    super.key,
    required this.controller,
  });

  @override
  State<DescriptionTextField> createState() => _DescriptionTextFieldState();
}

class _DescriptionTextFieldState extends State<DescriptionTextField> {
  /// FocusNode to detect when the field is focused and apply the purple border.
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    // Initialize focus node for custom border behavior on focus
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    // Always dispose FocusNode to prevent memory leaks
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        // Allows the field to grow vertically as the user types
        maxLines: null,
        // Minimum visible lines when empty or short
        minLines: 4,
        // Enforce character limit
        maxLength: widget.charLimit,
        // Text style using Space Grotesk font with precise typography
        style: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w400,
          height: 28 / 20, // Line height of 28px for 20sp text
          letterSpacing: -0.2,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          // Placeholder hint
          hintText: '/Describe your perfect hotspot',
          hintStyle: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.2,
            color: Colors.white.withOpacity(0.24), // Subtle gray hint
          ),
          // Background fill for dark theme consistency
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          // Inner padding for comfortable text entry
          contentPadding: const EdgeInsets.all(16),
          // Hide the default character counter (we don't show it in UI)
          counterText: '',
          // Default border (no visible border when not focused)
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          // Same as default when enabled but not focused
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          // Highlight border when focused – solid purple accent
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Color.fromRGBO(145, 150, 255, 1), // Brand purple (#9196FF)
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}