/// التحقق من المدخلات — قواعد موحدة عبر التطبيق
class Validators {
  Validators._();

  // ══════════════════════════════════════════
  //  رقم الهاتف
  // ══════════════════════════════════════════

  /// التحقق حسب كود الدولة
  static String? phone(String? value, int requiredDigits) {
    if (value == null || value.isEmpty) {
      return 'أدخل رقم الهاتف';
    }
    // إزالة المسافات
    final cleaned = value.replaceAll(' ', '');
    if (!RegExp(r'^[0-9]+$').hasMatch(cleaned)) {
      return 'أدخل أرقاماً فقط';
    }
    if (cleaned.length < requiredDigits - 1) {
      return 'رقم الهاتف غير مكتمل';
    }
    return null;
  }

  /// أردني
  static String? jordanPhone(String? value) => phone(value, 9);

  /// سعودي
  static String? saudiPhone(String? value) => phone(value, 9);

  /// عراقي
  static String? iraqiPhone(String? value) => phone(value, 10);

  // ══════════════════════════════════════════
  //  الاسم
  // ══════════════════════════════════════════

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'أدخل الاسم';
    }
    if (value.trim().length < 2) {
      return 'الاسم قصير جداً';
    }
    if (value.trim().length > 50) {
      return 'الاسم طويل جداً';
    }
    return null;
  }

  // ══════════════════════════════════════════
  //  البريد الإلكتروني
  // ══════════════════════════════════════════

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // اختياري
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'بريد إلكتروني غير صالح';
    }
    return null;
  }

  // ══════════════════════════════════════════
  //  OTP
  // ══════════════════════════════════════════

  static String? otp(String? value, {int length = 6}) {
    if (value == null || value.isEmpty) {
      return 'أدخل رمز التحقق';
    }
    if (value.length != length) {
      return 'الرمز يجب أن يكون $length أرقام';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'أدخل أرقاماً فقط';
    }
    return null;
  }

  // ══════════════════════════════════════════
  //  تاريخ الميلاد
  // ══════════════════════════════════════════

  static String? birthDate(DateTime? value) {
    if (value == null) return null; // اختياري
    final now = DateTime.now();
    final age = now.year - value.year;
    if (age < 10 || age > 120) {
      return 'تاريخ ميلاد غير صالح';
    }
    return null;
  }

  // ══════════════════════════════════════════
  //  ملاحظات الطلب
  // ══════════════════════════════════════════

  static String? orderNotes(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length > 500) {
      return 'الملاحظات طويلة جداً (500 حرف كحد أقصى)';
    }
    return null;
  }
}
