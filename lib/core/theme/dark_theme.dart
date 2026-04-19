import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import '../constants/app_sizes.dart';

/// الثيم الداكن — الافتراضي (يعكس هوية شلمونة الفاخرة)
ThemeData buildDarkTheme() {
  final textTheme = AppTypography.textTheme(
    AppColors.darkTextPrimary,
    AppColors.darkTextSecondary,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // ─── الألوان ───
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryYellow,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.primaryYellowLight,
      onSecondary: AppColors.onPrimary,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      error: AppColors.error,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,

    // ─── النصوص ───
    textTheme: textTheme,

    // ─── AppBar ───
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: textTheme.headlineMedium,
      iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),

    // ─── البطاقات ───
    cardTheme: CardThemeData(
      color: AppColors.darkCard,
      elevation: 0,
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
        elevation: 0,
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
        foregroundColor: AppColors.primaryYellow,
        side: const BorderSide(color: AppColors.primaryYellow, width: 1.5),
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
        foregroundColor: AppColors.primaryYellow,
        textStyle: textTheme.labelMedium,
      ),
    ),

    // ─── حقول الإدخال ───
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkInputFill,
      hintStyle: textTheme.bodyMedium?.copyWith(
        color: AppColors.darkTextHint,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMD,
        vertical: AppSizes.paddingMD,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        borderSide: const BorderSide(color: AppColors.darkInputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        borderSide: const BorderSide(color: AppColors.darkInputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        borderSide: const BorderSide(color: AppColors.primaryYellow, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    ),

    // ─── شريط التنقل السفلي ───
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkBottomNav,
      selectedItemColor: AppColors.primaryYellow,
      unselectedItemColor: AppColors.darkTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    // ─── الفواصل ───
    dividerTheme: const DividerThemeData(
      color: AppColors.darkDivider,
      thickness: 0.5,
      space: 0,
    ),

    // ─── Chips (للتصنيفات) ───
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.darkCard,
      selectedColor: AppColors.primaryYellow,
      labelStyle: textTheme.labelMedium!,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      side: const BorderSide(color: AppColors.darkDivider),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMD,
        vertical: AppSizes.paddingSM,
      ),
    ),

    // ─── Slider (للسكر والثلج) ───
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.primaryYellow,
      inactiveTrackColor: AppColors.darkCard,
      thumbColor: AppColors.primaryYellow,
      overlayColor: AppColors.primaryYellow.withValues(alpha: 0.2),
      trackHeight: 6,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
    ),

    // ─── Checkbox (للإضافات) ───
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryYellow;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(AppColors.onPrimary),
      side: const BorderSide(color: AppColors.darkTextSecondary, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),

    // ─── حوار (Dialog) ───
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.darkCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
      ),
    ),

    // ─── SnackBar ───
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.darkCard,
      contentTextStyle: textTheme.bodyMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      ),
      behavior: SnackBarBehavior.floating,
    ),

    // ─── BottomSheet ───
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXL),
        ),
      ),
    ),

    // ─── الأيقونات ───
    iconTheme: const IconThemeData(
      color: AppColors.darkTextPrimary,
      size: AppSizes.iconMD,
    ),

    // ─── ProgressIndicator ───
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryYellow,
      linearTrackColor: AppColors.darkCard,
    ),
  );
}
