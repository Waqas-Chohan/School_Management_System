import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Placeholder for the "Class" tab. To be designed from Figma.
class ClassScreen extends StatelessWidget {
  const ClassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Class',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF161616),
          ),
        ),
      ),
      body: Center(
        child: Text(
          'Class\n(coming soon)',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF737373),
          ),
        ),
      ),
    );
  }
}