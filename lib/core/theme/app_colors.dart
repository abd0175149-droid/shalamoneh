import 'package:flutter/material.dart';

/// ألوان هوية شلمونة — مستخرجة من DESIGN_SYSTEM.md
/// يدعم Dark Mode + Light Mode
class AppColors {
  AppColors._();

  // ══════════════════════════════════════════
  //  اللون الرئيسي — أصفر شلمونة (ثابت في الوضعين)
  // ══════════════════════════════════════════
  static const Color primaryYellow = Color(0xFFFFD400);
  static const Color primaryYellowLight = Color(0xFFFFE14D);
  static const Color primaryYellowDark = Color(0xFFE6BF00);
  static const Color onPrimary = Color(0xFF000000); // نص فوق الأصفر = أسود

  // ══════════════════════════════════════════
  //  الوضع الداكن (Dark Theme) — الافتراضي
  // ══════════════════════════════════════════
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1E1E1E);
  static const Color darkCardHover = Color(0xFF2A2A2A);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFA0A0A0);
  static const Color darkTextHint = Color(0xFF6B6B6B);
  static const Color darkDivider = Color(0xFF2C2C2C);
  static const Color darkInputFill = Color(0xFF1A1A1A);
  static const Color darkInputBorder = Color(0xFF333333);
  static const Color darkBottomNav = Color(0xFF0A0A0A);
  static const Color darkShimmerBase = Color(0xFF1E1E1E);
  static const Color darkShimmerHighlight = Color(0xFF2C2C2C);

  // ══════════════════════════════════════════
  //  الوضع الفاتح (Light Theme)
  // ══════════════════════════════════════════
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFF5F5F5);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardHover = Color(0xFFF0F0F0);
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF757575);
  static const Color lightTextHint = Color(0xFF9E9E9E);
  static const Color lightDivider = Color(0xFFE0E0E0);
  static const Color lightInputFill = Color(0xFFF5F5F5);
  static const Color lightInputBorder = Color(0xFFE0E0E0);
  static const Color lightBottomNav = Color(0xFFFFFFFF);
  static const Color lightShimmerBase = Color(0xFFE0E0E0);
  static const Color lightShimmerHighlight = Color(0xFFF5F5F5);

  // ══════════════════════════════════════════
  //  ألوان الحالة (مشتركة)
  // ══════════════════════════════════════════
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color info = Color(0xFF2196F3);

  // ══════════════════════════════════════════
  //  ألوان إضافية للعصائر والتصنيفات
  // ══════════════════════════════════════════
  static const Color juiceOrange = Color(0xFFFF6B35);
  static const Color juiceGreen = Color(0xFF66BB6A);
  static const Color juicePink = Color(0xFFEC407A);
  static const Color juicePurple = Color(0xFF7E57C2);
  static const Color hotDrink = Color(0xFF8D6E63);
  static const Color dessert = Color(0xFFFFAB91);

  // ══════════════════════════════════════════
  //  Gradient مشترك
  // ══════════════════════════════════════════
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryYellow, primaryYellowLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkOverlayGradient = LinearGradient(
    colors: [Colors.transparent, Color(0xCC000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
