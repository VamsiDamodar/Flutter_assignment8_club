import 'package:flutter/material.dart';
import 'screens/experience_selection_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hotspot Host Onboarding',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF101010),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF101010),
          brightness: Brightness.dark,
          primary: Colors.white,
          surface: const Color(0xFF1E1E1E),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white70),
          titleLarge: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(color: Colors.grey),
          contentPadding: const EdgeInsets.all(16),
          counterStyle: const TextStyle(color: Colors.grey),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF101010),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: const ExperienceSelectionScreen(),
    );
  }
}