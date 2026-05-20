import 'package:flutter/material.dart';

/// Central color palette. Change values here to re-skin the whole app.
///
/// Defaults match the Janna brand (dark teal + orange) — the same values the
/// backend seeder writes into `app_settings.primary_color` /
/// `secondary_color`. The splash screen reads the live values from the API
/// and uses these constants as a fallback while the request is in flight.
class AppColors {
  AppColors._();

  static const Color primary       = Color(0xFF0F4C45); // Janna dark teal
  static const Color primaryLight  = Color(0xFF1A7A6F);
  static const Color accent        = Color(0xFFF2A11F); // Janna orange — featured
  static const Color success       = Color(0xFF10B981);
  static const Color whatsapp      = Color(0xFF25D366);
  static const Color danger        = Color(0xFFEF4444);

  static const Color background    = Color(0xFFF7F8FA);
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color border        = Color(0xFFE5E7EB);

  static const Color textPrimary   = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted     = Color(0xFF9CA3AF);

  // Category-tile chip — teal-tinted to harmonize with the primary.
  static const Color chipBg        = Color(0xFFE6F2F0);
  static const Color chipFg        = Color(0xFF0F4C45);
}
