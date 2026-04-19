/// نقاط الوصول للـ API — متطابقة مع Backend الحقيقي
class ApiEndpoints {
  ApiEndpoints._();

  // ─── المصادقة ───
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String refreshToken = '/auth/refresh-token';
  static const String googleAuth = '/auth/google';
  static const String logout = '/auth/logout';
  static const String profile = '/auth/profile';

  // ─── المنيو ───
  static const String categories = '/categories';
  static const String products = '/products';
  static String productById(String id) => '/products/$id';

  // ─── الطلبات ───
  static const String orders = '/orders';
  static String orderById(String id) => '/orders/$id';

  // ─── الولاء ───
  static const String loyaltyBalance = '/loyalty/balance';
  static const String loyaltyTransactions = '/loyalty/transactions';
  static const String loyaltyRedeem = '/loyalty/redeem';

  // ─── المفضلات ───
  static const String favorites = '/favorites';
  static const String favoriteIds = '/favorites/ids';
  static String removeFavorite(String productId) => '/favorites/$productId';

  // ─── الفروع ───
  static const String branches = '/branches';
  static String branchById(String id) => '/branches/$id';

  // ─── عام ───
  static const String health = '/health';
}
