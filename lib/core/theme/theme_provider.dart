import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_theme.dart';

final themeProvider = Provider<ThemeData>((ref) {
  // For now, we only have light theme
  // In the future, we can add theme switching logic here
  return AppTheme.lightTheme;
});
