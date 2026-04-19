import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// نظام الخطوط — من DESIGN_SYSTEM.md
/// العناوين: خط مرح (Baloo Bhaijaan 2)
/// النصوص الوظيفية: Cairo
class AppTypography {
  AppTypography._();

  // ══════════════════════════════════════════
  //  الخط المرح للعناوين والشعارات
  // ══════════════════════════════════════════
  static TextStyle _displayFont({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w700,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.balooBhaijaan2(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // ══════════════════════════════════════════
  //  الخط الوظيفي للنصوص والأسعار
  // ══════════════════════════════════════════
  static TextStyle _bodyFont({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.cairo(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // ══════════════════════════════════════════
  //  TextTheme كامل
  // ══════════════════════════════════════════
  static TextTheme textTheme(Color primaryColor, Color secondaryColor) {
    return TextTheme(
      // العناوين الكبيرة — خط مرح
      displayLarge: _displayFont(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        color: primaryColor,
        height: 1.2,
      ),
      displayMedium: _displayFont(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: primaryColor,
        height: 1.25,
      ),
      displaySmall: _displayFont(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: primaryColor,
        height: 1.3,
      ),

      // عناوين الأقسام — خط مرح
      headlineLarge: _displayFont(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: primaryColor,
        height: 1.3,
      ),
      headlineMedium: _displayFont(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        height: 1.35,
      ),
      headlineSmall: _displayFont(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        height: 1.35,
      ),

      // عناوين البطاقات — Cairo Bold
      titleLarge: _bodyFont(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: primaryColor,
        height: 1.4,
      ),
      titleMedium: _bodyFont(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        height: 1.4,
      ),
      titleSmall: _bodyFont(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        height: 1.4,
      ),

      // النصوص الأساسية — Cairo Regular
      bodyLarge: _bodyFont(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: primaryColor,
        height: 1.5,
      ),
      bodyMedium: _bodyFont(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: primaryColor,
        height: 1.5,
      ),
      bodySmall: _bodyFont(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
        height: 1.5,
      ),

      // نصوص الأزرار والتسميات — Cairo Bold
      labelLarge: _bodyFont(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: primaryColor,
        height: 1.2,
      ),
      labelMedium: _bodyFont(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        height: 1.2,
      ),
      labelSmall: _bodyFont(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
        height: 1.2,
      ),
    );
  }

  // ══════════════════════════════════════════
  //  أنماط خاصة — خارج TextTheme
  // ══════════════════════════════════════════

  /// سعر المنتج (كبير وبارز)
  static TextStyle priceStyle({Color? color}) => _bodyFont(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: -0.5,
      );

  /// سعر الإضافة (صغير)
  static TextStyle addonPriceStyle({Color? color}) => _bodyFont(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: color,
      );

  /// رقم النقاط (ضخم)
  static TextStyle pointsLargeStyle({Color? color}) => _displayFont(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        color: color,
        height: 1.0,
      );

  /// Badge المستوى
  static TextStyle levelBadgeStyle({Color? color}) => _displayFont(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 0.5,
      );
}
