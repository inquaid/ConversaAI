import 'package:flutter/material.dart';

class AppColors {
  // Modern Primary Colors - Deep Purple/Blue gradient
  static const primaryPurple = Color(0xFF6366F1);
  static const primaryBlue = Color(0xFF3B82F6);
  static const primaryDark = Color(0xFF1E40AF);
  static const primaryLight = Color(0xFFE0E7FF);

  // Modern Secondary Colors - Emerald/Teal
  static const accent = Color(0xFF10B981);
  static const accentLight = Color(0xFF6EE7B7);
  static const accentDark = Color(0xFF047857);

  // Modern Background Colors
  static const background = Color(0xFFF8FAFC);
  static const backgroundDark = Color(0xFF0F172A);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF1F5F9);
  static const cardBackground = Color(0xFFFFFFFF);

  // Modern Text Colors
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textTertiary = Color(0xFF94A3B8);
  static const textOnPrimary = Color(0xFFFFFFFF);
  static const textOnSurface = Color(0xFF1E293B);

  // Status Colors
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  // Speaking/Listening States - Modern Colors
  static const speakingActive = Color(0xFF8B5CF6);
  static const speakingGradientStart = Color(0xFF8B5CF6);
  static const speakingGradientEnd = Color(0xFFA855F7);

  static const listeningActive = Color(0xFF06B6D4);
  static const listeningGradientStart = Color(0xFF06B6D4);
  static const listeningGradientEnd = Color(0xFF0EA5E9);

  static const inactive = Color(0xFF94A3B8);

  // Modern Gradient Colors
  static const gradientStart = Color(0xFF6366F1);
  static const gradientMiddle = Color(0xFF8B5CF6);
  static const gradientEnd = Color(0xFFA855F7);

  // Modern Brand Gradient
  static const brandGradientStart = Color(0xFF667EEA);
  static const brandGradientEnd = Color(0xFF764BA2);

  // Modern Card Shadows
  static const shadowColor = Color(0x1A000000);
  static const shadowColorDark = Color(0x40000000);
}

class AppDimensions {
  // Modern Padding & Margins
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;
  static const double paddingXXXL = 64.0;

  // Modern Border Radius
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusXXL = 32.0;
  static const double radiusCircle = 999.0;

  // Modern Button Heights
  static const double buttonHeight = 56.0;
  static const double buttonHeightLarge = 64.0;
  static const double buttonHeightSmall = 40.0;

  // Modern Icon Sizes
  static const double iconXS = 12.0;
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;
  static const double iconXXL = 64.0;
  static const double iconXXXL = 96.0;

  // Modern Animation Sizes
  static const double animationSizeSmall = 120.0;
  static const double animationSizeMedium = 200.0;
  static const double animationSizeLarge = 280.0;
  static const double animationSizeXLarge = 360.0;

  // Modern Elevation
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;
  static const double elevationXL = 12.0;
}

class AppDurations {
  static const Duration splash = Duration(seconds: 3);
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration animationExtraSlow = Duration(milliseconds: 800);
  static const Duration pulseAnimation = Duration(milliseconds: 1200);
  static const Duration waveAnimation = Duration(milliseconds: 2000);
}
