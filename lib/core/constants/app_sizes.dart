/// ثوابت الأحجام والمسافات — تمنع الأرقام العشوائية في الكود
class AppSizes {
  AppSizes._();

  // ══════════════════════════════════════════
  //  Padding / Margin
  // ══════════════════════════════════════════
  static const double paddingXS = 4.0;
  static const double paddingSM = 8.0;
  static const double paddingMD = 16.0;
  static const double paddingLG = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;

  // ══════════════════════════════════════════
  //  Border Radius (من DESIGN_SYSTEM.md = 16px)
  // ══════════════════════════════════════════
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0; // الافتراضي حسب الهوية
  static const double radiusXL = 24.0;
  static const double radiusFull = 999.0;

  // ══════════════════════════════════════════
  //  Icon Sizes
  // ══════════════════════════════════════════
  static const double iconSM = 18.0;
  static const double iconMD = 24.0;
  static const double iconLG = 32.0;
  static const double iconXL = 48.0;

  // ══════════════════════════════════════════
  //  Component Heights
  // ══════════════════════════════════════════
  static const double buttonHeight = 52.0;
  static const double inputHeight = 52.0;
  static const double appBarHeight = 56.0;
  static const double bottomNavHeight = 70.0;
  static const double fabSize = 64.0;
  static const double productCardHeight = 220.0;
  static const double bannerHeight = 180.0;

  // ══════════════════════════════════════════
  //  Drink Sizes (for product customization)
  // ══════════════════════════════════════════
  static const double drinkSizeS = 40.0;
  static const double drinkSizeM = 48.0;
  static const double drinkSizeL = 56.0;

  // ══════════════════════════════════════════
  //  Animation Durations (ms)
  // ══════════════════════════════════════════
  static const int animFast = 200;
  static const int animNormal = 350;
  static const int animSlow = 500;
  static const int animBanner = 4000; // Auto-scroll interval

  // ══════════════════════════════════════════
  //  Grid
  // ══════════════════════════════════════════
  static const int menuGridColumns = 2;
  static const double menuGridSpacing = 12.0;
  static const double menuGridChildAspectRatio = 0.72;
}
