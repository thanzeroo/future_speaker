import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  // Primary palette - modern vibrant blue
  static const Color primary = Color(0xFF1E60FF);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF174BC4);
  static const Color primarySurface = Color(0xFFEEF4FF);
  static const Color primarySurfaceLight = Color(0xFFF5F8FF);

  // Accent - electric cyan & soft sky
  static const Color accent = Color(0xFF00C6FF);
  static const Color accentSoft = Color(0xFFBAE6FD);

  // Background
  static const Color background = Color(0xFFF3F7FC);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFEAF1FA);

  // Text
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF64748B);
  static const Color textOnPrimary = Colors.white;

  // Status - Clean harmonious palette (No strange alarming reds)
  static const Color online = Color(0xFF10B981);
  static const Color offline = Color(0xFF94A3B8);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFF64748B); // Refined calm slate instead of alarming red

  // Connection badge - Blue when connected, sleek cool slate when disconnected
  static const Color connectedBg = Color(0xFFE0F2FE);
  static const Color connectedText = Color(0xFF0369A1);
  static const Color disconnectedBg = Color(0xFFF1F5F9);
  static const Color disconnectedText = Color(0xFF475569);

  // Slider
  static const Color sliderActive = Color(0xFF1E60FF);
  static const Color sliderInactive = Color(0xFFD6E4FF);

  // Card
  static const Color cardBorder = Color(0xFFE2EBF6);

  // Disconnect button - Clean subtle slate & ice blue (No strange red)
  static const Color disconnectBg = Color(0xFFF8FAFC);
  static const Color disconnectText = Color(0xFF475569);
  static const Color disconnectBorder = Color(0xFFCBD5E1);

  // Toggle
  static const Color toggleActive = Color(0xFF1E60FF);
  static const Color toggleInactive = Color(0xFFCBD5E1);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.textOnPrimary,
        secondary: AppColors.primaryLight,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.cardBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.sliderActive,
        inactiveTrackColor: AppColors.sliderInactive,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withValues(alpha: 0.12),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
