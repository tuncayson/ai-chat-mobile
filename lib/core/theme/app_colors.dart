import 'package:flutter/material.dart';

/// Brand and semantic colors for the app. Dark-first: dark values are the
/// primary design target; light values exist for the optional light theme.
@immutable
abstract final class AppColors {
  // Brand accent — single bright color used across both themes.
  static const Color accent = Color(0xFF8B5CF6); // violet-500
  static const Color accentDim = Color(0xFF6D28D9); // violet-700 (light theme)
  static const Color onAccent = Color(0xFFFFFFFF);

  // Dark palette (primary).
  static const Color darkBackground = Color(0xFF0B0B0F);
  static const Color darkSurface = Color(0xFF15151B);
  static const Color darkSurfaceVariant = Color(0xFF1F1F28);
  static const Color darkSurfaceHigh = Color(0xFF26262F);
  static const Color darkOnBackground = Color(0xFFE5E7EB);
  static const Color darkOnSurface = Color(0xFFE5E7EB);
  static const Color darkOnSurfaceMuted = Color(0xFF9CA3AF);
  static const Color darkOutline = Color(0xFF2A2A33);

  // Light palette (secondary).
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F1F4);
  static const Color lightSurfaceHigh = Color(0xFFEAEAEF);
  static const Color lightOnBackground = Color(0xFF111827);
  static const Color lightOnSurface = Color(0xFF111827);
  static const Color lightOnSurfaceMuted = Color(0xFF6B7280);
  static const Color lightOutline = Color(0xFFE5E7EB);

  // Shared semantic colors.
  static const Color error = Color(0xFFEF4444);
  static const Color onError = Color(0xFFFFFFFF);
}
