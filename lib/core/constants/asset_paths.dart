/// مسارات الأصول — صور وأيقونات
/// في الإنتاج: ستُملأ بمسارات الصور الحقيقية
class AssetPaths {
  AssetPaths._();

  // ─── المجلدات ───
  static const String _images = 'assets/images';
  static const String _icons = 'assets/icons';
  static const String _lottie = 'assets/lottie';

  // ─── اللوجو ───
  static const String logo = '$_images/logo.png';
  static const String logoWhite = '$_images/logo_white.png';
  static const String logoYellow = '$_images/logo_yellow.png';

  // ─── Onboarding ───
  static const String onboarding1 = '$_images/onboarding_1.png';
  static const String onboarding2 = '$_images/onboarding_2.png';
  static const String onboarding3 = '$_images/onboarding_3.png';

  // ─── Splash ───
  static const String splashBg = '$_images/splash_bg.png';

  // ─── منتجات (Placeholder) ───
  static const String productPlaceholder = '$_images/product_placeholder.png';
  static const String categoryPlaceholder = '$_images/category_placeholder.png';

  // ─── رسوم متحركة ───
  static const String loadingLottie = '$_lottie/loading.json';
  static const String successLottie = '$_lottie/success.json';
  static const String emptyCartLottie = '$_lottie/empty_cart.json';

  // ─── أعلام الدول ───
  static const String flagJordan = '$_icons/flag_jo.png';
  static const String flagSaudi = '$_icons/flag_sa.png';
  static const String flagIraq = '$_icons/flag_iq.png';
  static const String flagPalestine = '$_icons/flag_ps.png';
}
