/// النصوص الثابتة — العربية (الافتراضية)
/// جاهز للربط مع نظام ترجمة (intl/easy_localization)
class AppStrings {
  AppStrings._();

  // ══════════════════════════════════════════
  //  عام
  // ══════════════════════════════════════════
  static const appName = 'شلمونة';
  static const appNameEn = 'Shalmoneh';
  static const appSlogan = 'طعم الحياة';
  static const appSloganEn = 'Taste of Life';
  static const version = '1.0.0';

  // ══════════════════════════════════════════
  //  المصادقة
  // ══════════════════════════════════════════
  static const loginTitle = 'تسجيل الدخول 📱';
  static const loginSubtitle = 'أدخل رقم هاتفك وسنرسل لك رمز التحقق';
  static const phoneLabel = 'رقم الهاتف';
  static const phoneHint = '7XXXXXXXX';
  static const countryLabel = 'الدولة';
  static const continueBtn = 'متابعة';
  static const sendingBtn = 'جاري الإرسال...';
  static const otpTitle = 'رمز التحقق 🔐';
  static const otpSentTo = 'تم إرسال رمز مكون من 6 أرقام إلى';
  static const otpEdit = 'تعديل';
  static const otpVerify = 'تحقق';
  static const otpResend = 'إعادة إرسال الرمز';
  static const otpResendIn = 'إعادة الإرسال بعد';
  static const otpSuccess = 'تم التحقق بنجاح! ✨';
  static const termsText = 'بالمتابعة أنت توافق على';
  static const termsOfService = 'شروط الاستخدام';
  static const privacyPolicy = 'سياسة الخصوصية';

  // ══════════════════════════════════════════
  //  الرئيسية
  // ══════════════════════════════════════════
  static const popularTitle = '🔥 الأكثر طلباً';
  static const viewAll = 'عرض الكل';
  static const categoriesTitle = '📂 التصنيفات';
  static const loyaltyMiniTitle = 'شلموناتك';
  static const freeDrinkMsg = 'شلمونة للمشروب المجاني!';

  // ══════════════════════════════════════════
  //  المنيو
  // ══════════════════════════════════════════
  static const menuTitle = 'المنيو 🥤';
  static const searchHint = 'ابحث عن مشروبك...';
  static const noResults = 'لا توجد نتائج';
  static const sizeLabel = '📏 الحجم';
  static const sugarLabel = '🍬 نسبة السكر';
  static const iceLabel = '🧊 نسبة الثلج';
  static const addonsLabel = '✨ الإضافات';
  static const addToCart = 'أضف للسلة';
  static const addedToCart = 'تمت الإضافة للسلة ✨';
  static const currency = 'JOD';

  // ══════════════════════════════════════════
  //  السلة
  // ══════════════════════════════════════════
  static const cartTitle = 'السلة';
  static const cartEmpty = 'سلتك فارغة';
  static const cartEmptyMsg = 'اكتشف المنيو وأضف مشروبك المفضل!';
  static const browseMenu = 'تصفح المنيو 🥤';
  static const clearCart = 'تفريغ السلة';
  static const clearCartConfirm = 'هل أنت متأكد من حذف جميع العناصر؟';
  static const deleteAll = 'حذف الكل';
  static const cancel = 'إلغاء';
  static const subtotal = 'المجموع الفرعي';
  static const tax = 'الضريبة';
  static const total = 'المجموع الكلي';
  static const confirmOrder = 'تأكيد الطلب 🛒';

  // ══════════════════════════════════════════
  //  الدفع
  // ══════════════════════════════════════════
  static const checkoutTitle = 'تأكيد الطلب';
  static const orderType = 'نوع الاستلام';
  static const branchLabel = 'الفرع';
  static const orderSummary = 'ملخص الطلب';
  static const notes = 'ملاحظات إضافية';
  static const notesHint = 'أي ملاحظات خاصة بالطلب...';
  static const placeOrder = 'تأكيد وإرسال الطلب ✅';
  static const orderSuccess = 'تم تأكيد الطلب! ✅';
  static const estimatedTime = 'الوقت المتوقع: 10-15 دقيقة';
  static const backToHome = 'العودة للرئيسية 🏠';

  // ══════════════════════════════════════════
  //  الولاء
  // ══════════════════════════════════════════
  static const loyaltyTitle = 'شلموناتي ⭐';
  static const scanQr = 'امسح الكود عند الكاشير';
  static const pointsHistory = 'سجل النقاط';
  static const earned = 'مكتسبة';
  static const redeemed = 'مستبدلة';

  // ══════════════════════════════════════════
  //  الفروع
  // ══════════════════════════════════════════
  static const branchesTitle = 'الفروع 📍';
  static const allCities = 'الكل';
  static const openNow = 'مفتوح';
  static const closed = 'مغلق';
  static const km = 'كم';
  static const orderFromBranch = 'اطلب من هذا الفرع 🛒';
  static const noBranches = 'لا توجد فروع';

  // ══════════════════════════════════════════
  //  البروفايل
  // ══════════════════════════════════════════
  static const editProfile = 'تعديل البيانات الشخصية';
  static const orderHistory = 'تاريخ الطلبات';
  static const favorites = 'المشروبات المفضلة';
  static const darkMode = 'الوضع الداكن';
  static const ourStory = 'قصة شلمونة';
  static const logout = 'تسجيل الخروج';

  // ══════════════════════════════════════════
  //  أخطاء
  // ══════════════════════════════════════════
  static const errorGeneric = 'حدث خطأ. حاول مجدداً.';
  static const errorNoInternet = 'لا يوجد اتصال بالإنترنت';
  static const errorTimeout = 'انتهت مهلة الاتصال';
  static const errorServer = 'خطأ في السيرفر';

  // ══════════════════════════════════════════
  //  Onboarding
  // ══════════════════════════════════════════
  static const onboarding1Title = 'مرحباً بك في شلمونة! 🥤';
  static const onboarding1Sub = 'اكتشف أشهى العصائر الطبيعية';
  static const onboarding2Title = 'اطلب بسهولة 📱';
  static const onboarding2Sub = 'خصص مشروبك واطلبه من هاتفك';
  static const onboarding3Title = 'اجمع شلموناتك ⭐';
  static const onboarding3Sub = 'واحصل على مشروبات مجانية';
  static const getStarted = 'يلا نبدأ! 🚀';
  static const skip = 'تخطي';
  static const next = 'التالي';
}
