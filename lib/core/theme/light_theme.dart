import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import '../constants/app_sizes.dart';

/// الثيم الفاتح — بديل اختياري مع الحفاظ على هوية شلمونة
ThemeData buildLightTheme() {
  final textTheme = AppTypography.textTheme(
    AppColors.lightTextPrimary,
    AppColors.lightTextSecondary,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // ─── الألوان ───
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryYellow,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.primaryYellowDark,
      onSecondary: AppColors.onPrimary,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightTextPrimary,
      error: AppColors.error,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,

    // ─── النصوص ───
    textTheme: textTheme,

    // ─── AppBar ───
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.lightBackground,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: true,
      titleTextStyle: textTheme.headlineMedium,
      iconTheme: const IconThemeData(color: AppColors.lightTextPrimary),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),

    // ─── البطاقات ───
    cardTheme: CardThemeData(
      color: AppColors.lightCard,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSM,
        vertical: AppSizes.paddingXS,
      ),
    ),

    // ─── الأزرار الرئيسية (أصفر) ───
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryYellow,
        foregroundColor: AppColors.onPrimary,
        elevation: 2,
        shadowColor: AppColors.primaryYellow.withValues(alpha: 0.3),
        minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        ),
        textStyle: textTheme.labelLarge?.copyWith(
          color: AppColors.onPrimary,
        ),
      ),
    ),

    // ─── الأزرار الثانوية ───
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryYellowDark,
        side: const BorderSide(color: AppColors.primaryYellowDark, width: 1.5),
        minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        ),
        textStyle: textTheme.labelLarge,
      ),
    ),

    // ─── الأزرار النصية ───
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryYellowDark,
        textStyle: textTheme.labelMedium,
      ),
    ),

    // ─── حقول الإدخال ───
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightInputFill,
      hintStyle: textTheme.bodyMedium?.copyWith(
        color: AppColors.lightTextHint,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMD,
        vertical: AppSizes.paddingMD,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        borderSide: const BorderSide(color: AppColors.lightInputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        borderSide: const BorderSide(color: AppColors.lightInputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        borderSide: const BorderSide(color: AppColors.primaryYellowDark, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    ),

    // ─── شريط التنقل السفلي ───
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightBottomNav,
      selectedItemColor: AppColors.primaryYellowDark,
      unselectedItemColor: AppColors.lightTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    // ─── الفواصل ───
    dividerTheme: const DividerThemeData(
      color: AppColors.lightDivider,
      thickness: 0.5,
      space: 0,
    ),

    // ─── Chips ───
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.lightCard,
      selectedColor: AppColors.primaryYellow,
      labelStyle: textTheme.labelMedium!,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      side: const BorderSide(color: AppColors.lightDivider),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMD,
        vertical: AppSizes.paddingSM,
      ),
    ),

    // ─── Slider ───
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.primaryYellowDark,
      inactiveTrackColor: AppColors.lightDivider,
      thumbColor: AppColors.primaryYellowDark,
      overlayColor: AppColors.primaryYellowDark.withValues(alpha: 0.15),
      trackHeight: 6,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
    ),

    // ─── Checkbox ───
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryYellowDark;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(AppColors.onPrimary),
      side: const BorderSide(color: AppColors.lightTextSecondary, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),

    // ─── Dialog ───
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.lightCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
      ),
    ),

    // ─── SnackBar ───
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.lightTextPrimary,
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      ),
      behavior: SnackBarBehavior.floating,
    ),

    // ─── BottomSheet ───
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.lightCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXL),
        ),
      ),
    ),

    // ─── الأيقونات ───
    iconTheme: const IconThemeData(
      color: AppColors.lightTextPrimary,
      size: AppSizes.iconMD,
    ),

    // ─── ProgressIndicator ───
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryYellowDark,
      linearTrackColor: AppColors.lightDivider,
    ),
  );
}
