/// نقطة الوصول للـ API — تُعدَّل عند الربط بالـ Backend
class ApiEndpoints {
  ApiEndpoints._();

  // القاعدة
  static const String baseUrl = 'https://api.shalmoneh.com/v1';

  // ─── المصادقة ───
  static const String sendOtp = '/auth/otp/send';
  static const String verifyOtp = '/auth/otp/verify';
  static const String refreshToken = '/auth/token/refresh';
  static const String logout = '/auth/logout';

  // ─── المستخدم ───
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile/update';
  static const String uploadAvatar = '/user/avatar';
  static const String deleteAccount = '/user/delete';

  // ─── المنيو ───
  static const String categories = '/menu/categories';
  static const String products = '/menu/products';
  static String productById(String id) => '/menu/products/$id';
  static String productsByCategory(String catId) => '/menu/categories/$catId/products';

  // ─── الطلبات ───
  static const String createOrder = '/orders';
  static const String orderHistory = '/orders/history';
  static String orderById(String id) => '/orders/$id';
  static String orderStatus(String id) => '/orders/$id/status';
  static String cancelOrder(String id) => '/orders/$id/cancel';
  static String reorder(String id) => '/orders/$id/reorder';

  // ─── الولاء ───
  static const String loyaltyBalance = '/loyalty/balance';
  static const String loyaltyTransactions = '/loyalty/transactions';
  static const String loyaltyRedeem = '/loyalty/redeem';

  // ─── الفروع ───
  static const String branches = '/branches';
  static String branchById(String id) => '/branches/$id';
  static const String nearbyBranches = '/branches/nearby';

  // ─── الإشعارات ───
  static const String notifications = '/notifications';
  static const String registerFcm = '/notifications/fcm/register';

  // ─── عام ───
  static const String appConfig = '/config';
  static const String ourStory = '/about/story';
  static const String privacyPolicy = '/about/privacy';
  static const String termsOfService = '/about/terms';
}
