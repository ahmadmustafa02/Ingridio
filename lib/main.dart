import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ingridio/screens/onboarding_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF9D4300);
    const Color background = Color(0xFFFFF8F5);

    return MaterialApp(
      title: 'Ingridio',
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: primary,
          surface: background,
          onSurface: Color(0xFF2F1400),
        ),
        scaffoldBackgroundColor: background,
        primaryColor: primary,
        textTheme: GoogleFonts.beVietnamProTextTheme(
          ThemeData.light().textTheme,
        ).copyWith(
          headlineLarge: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
          ),
          headlineMedium: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
          ),
          titleLarge: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
          ),
        ),
        useMaterial3: true,
      ),
      home: const OnboardingScreen(),
    );
  }
}
