import 'package:flutter/material.dart';

/// Convenient accessors for theme properties inside any build method.
extension ThemeContextExtension on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TargetPlatform get platform => Theme.of(this).platform;
}