// screens/experience_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vamsi_assignment/models/experience.dart';
import 'package:vamsi_assignment/services/api_service.dart';
import 'package:vamsi_assignment/widgets/experience_card.dart';
import 'package:vamsi_assignment/widgets/description_textfield.dart';
import 'package:vamsi_assignment/widgets/next_button.dart';
import 'package:vamsi_assignment/utils/wavy_progress_painter.dart';
import 'package:vamsi_assignment/screens/onboarding_question_screen.dart';

/// First step in the onboarding flow (step 01/04).
///
/// Allows users to:
/// • Select multiple hotspot categories they want to host (e.g., "Photography", "Food Tour")
/// • Write an optional description of their ideal hotspot
/// • Navigate forward only when at least one experience is selected
///
/// Visual highlights:
/// • Horizontal scrollable grid of ExperienceCards with selection state
/// • Full-width Next button with gradient and enabled/disabled states
class ExperienceSelectionScreen extends StatefulWidget {
  const ExperienceSelectionScreen({super.key});

  @override
  State<ExperienceSelectionScreen> createState() => _ExperienceSelectionScreenState();
}

class _ExperienceSelectionScreenState extends State<ExperienceSelectionScreen> {
  /// List of all available experiences fetched from the backend.
  List<Experience> experiences = [];

  /// IDs of currently selected experiences.
  List<int> selectedIds = [];

  /// Controller for the description text field.
  final TextEditingController descController = TextEditingController();

  /// Loading state while fetching experiences from API.
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExperiences(); // Fetch experiences on screen load
  }

  /// Fetches the list of experiences from the API.
  /// Updates UI on success, shows error snackbar on failure.
  Future<void> _loadExperiences() async {
    try {
      final data = await ApiService.fetchExperiences();
      setState(() {
        experiences = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading experiences: $e')),
      );
    }
  }

  /// Toggles selection of an experience by ID.
  /// Adds if not selected, removes if already selected.
  void _toggleSelection(int id) {
    setState(() {
      selectedIds.contains(id) ? selectedIds.remove(id) : selectedIds.add(id);
    });
  }

  /// Called when the user taps "Next".
  /// Logs current selections and description, then proceeds to the next onboarding screen.
  void _onNext() {
    debugPrint('Selected Experience IDs: $selectedIds');
    debugPrint('Description: ${descController.text}');

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingQuestionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Ensures layout adjusts when keyboard appears
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          color: const Color.fromRGBO(255, 255, 255, 0.02),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  // Back button
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    onPressed: () => Navigator.maybePop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  // Progress indicator (25% = step 1 of 4)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        height: 6,
                        child: WavyProgressBar(
                          progress: 0.25,
                          activeColor: const Color(0xFF9196FF),
                          inactiveColor: const Color(0xFF4A4A4A),
                        ),
                      ),
                    ),
                  ),
                  // Close onboarding (return to home)
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 24),
                    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 180), // Hero space for visual breathing room
              // Step indicator
              Text(
                '01',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 16 / 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              // Main question
              Text(
                'What kind of hotspots do you want to host?',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              // Horizontal grid of experience cards
              SizedBox(
                height: 140,
                child: isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF9196FF)))
                    : GridView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          childAspectRatio: 1,
                          mainAxisSpacing: 2,
                          crossAxisSpacing: 12,
                        ),
                        itemCount: experiences.length,
                        itemBuilder: (context, index) {
                          final exp = experiences[index];
                          final isSelected = selectedIds.contains(exp.id);
                          return ExperienceCard(
                            imageUrl: exp.imageUrl,
                            isSelected: isSelected,
                            onTap: () => _toggleSelection(exp.id),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 20),
              // Description input field
              DescriptionTextField(controller: descController),
              const SizedBox(height: 20),
              // Next button (enabled only when at least one experience is selected)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: NextButton(
                  onPressed: _onNext,
                  isEnabled: selectedIds.isNotEmpty,
                ),
              ),
              const SizedBox(height: 10), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}