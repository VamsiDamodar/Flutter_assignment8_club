// widgets/description_textfield.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A large, multiline text field optimized for long-form descriptions (up to 600 characters).
///
/// Features:
/// • Expands vertically as user types (starts at 7 lines)
/// • 600-character limit with hidden counter
/// • Clean dark theme styling with subtle background and purple focus border
/// • Uses Space Grotesk font for consistent typography
/// • Comfortable padding and rounded corners for modern look
/// • Hint text with low opacity for minimal distraction
///
/// Ideal for:
/// - User-generated content (reviews, captions, hotspot descriptions)
/// - Forms requiring detailed input
///
/// Usage:
/// ```dart
/// DescriptionTextField(controller: _descriptionController)
/// ```
class DescriptionTextField extends StatefulWidget {
  /// Controller to bind, read, and manage the input text.
  final TextEditingController controller;

  /// Maximum allowed characters. Increased to 600 for longer descriptions.
  final int charLimit = 600;

  const DescriptionTextField({
    super.key,
    required this.controller,
  });

  @override
  State<DescriptionTextField> createState() => _DescriptionTextFieldState();
}

class _DescriptionTextFieldState extends State<DescriptionTextField> {
  /// FocusNode to control and style the border when the field is active.
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    // Initialize focus node to enable custom focus styling
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    // Prevent memory leaks by disposing the focus node
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        
        // Allows unlimited lines – field grows vertically with content
        maxLines: null,
        
        // Minimum height equivalent to 7 lines when empty
        minLines: 7,
        
        // Enforces the 600-character limit
        maxLength: widget.charLimit,

        // Text style: clean, readable, modern
        style: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          color: Colors.white,
          height: 24 / 16, // 24px line height for 16sp text → better readability
        ),

        decoration: InputDecoration(
          // Placeholder text with leading slash for stylistic consistency
          hintText: '/ Start typing here',
          hintStyle: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            color: Colors.white.withOpacity(0.3), // Subtle hint visibility
          ),

          // Dark translucent background for depth in dark mode
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),

          // Generous inner padding for comfortable typing
          contentPadding: const EdgeInsets.all(20),

          // Hide default character counter (we don't display it in UI)
          counterText: '',

          // Default border: invisible when not focused
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),

          // Enabled but unfocused state – same as default
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),

          // Focused state: solid purple border for clear visual feedback
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color.fromRGBO(145, 150, 255, 1), // Brand purple accent (#9196FF)
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}