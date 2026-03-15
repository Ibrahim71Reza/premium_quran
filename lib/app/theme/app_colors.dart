import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF070B12);
  static const Color backgroundSecondary = Color(0xFF0E1420);

  static const Color surface = Color(0xFF111827);
  static const Color surfaceSoft = Color(0xFF172033);
  static const Color surfaceVariant = Color(0xFF1E293B);

  static const Color emerald = Color(0xFF10B981);
  static const Color emeraldSoft = Color(0xFF34D399);

  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color goldSoft = Color(0xFFF6D365);

  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  static const Color danger = Color(0xFFEF4444);

  static const LinearGradient premiumBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF070B12),
      Color(0xFF0E1420),
      Color(0xFF111827),
    ],
  );

  static const LinearGradient emeraldGlowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF10B981),
      Color(0xFF34D399),
    ],
  );

  static const LinearGradient goldGlowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFD4AF37),
      Color(0xFFF6D365),
    ],
  );
}