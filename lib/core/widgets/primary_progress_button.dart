import 'package:flutter/material.dart';

import '../config/app_dimensions.dart';
import '../extensions/theme_context_extension.dart';

/// A [FilledButton] that shows a loading spinner while [isLoading] is true
/// and ignores taps while loading.
class PrimaryProgressButton extends StatelessWidget {
  const PrimaryProgressButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.isLoading = false,
    this.icon,
  });

  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    return SizedBox(
      width: double.infinity,
      height: AppDimensions.buttonHeight,
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: isLoading
              ? context.colorScheme.primary.withValues(alpha: 0.6)
              : null,
          disabledBackgroundColor:
              context.colorScheme.primary.withValues(alpha: 0.6),
        ),
        child: isLoading
            ? SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: context.colorScheme.onPrimary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(label),
                ],
              ),
      ),
    );
  }
}