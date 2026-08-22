import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/config/app_dimensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/feature.dart';

class FeatureDetailScreen extends StatelessWidget {
  const FeatureDetailScreen({super.key, required this.feature});

  final Feature feature;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feature Details')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.defaultHorizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                feature.name,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.darkText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Status: ${feature.statusLabel}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.greyText,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'ID: ${feature.id}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.greyText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}