import 'dart:math';

/// خدمة رموز التحقق OTP
/// تدير: توليد الرمز، التحقق، انتهاء الصلاحية، عدد المحاولات
class OtpService {
  OtpService._();
  static final OtpService instance = OtpService._();

  String? _currentOtp;
  String? _currentPhone;
  DateTime? _expiresAt;
  int _attempts = 0;

  static const int otpLength = 6;
  static const int expiryMinutes = 5;
  static const int maxAttempts = 5;

  final _random = Random.secure();

  // ══════════════════════════════════════════
  //  توليد OTP جديد
  // ══════════════════════════════════════════

  /// يولّد رمز OTP عشوائي من 6 أرقام ويربطه برقم الهاتف
  /// يُعيد الرمز المُولَّد (في الإنتاج يُرسل عبر SMS ولا يُعاد)
  OtpResult generateOtp(String phoneNumber) {
    // توليد رقم عشوائي من 6 خانات
    final otp = List.generate(otpLength, (_) => _random.nextInt(10)).join();

    _currentOtp = otp;
    _currentPhone = phoneNumber;
    _expiresAt = DateTime.now().add(const Duration(minutes: expiryMinutes));
    _attempts = 0;

    return OtpResult(
      success: true,
      otp: otp, // في الإنتاج: لا يُعاد، يُرسل عبر SMS
      phone: phoneNumber,
      expiresAt: _expiresAt!,
      message: 'تم إرسال رمز التحقق إلى $phoneNumber',
    );
  }

  // ══════════════════════════════════════════
  //  التحقق من OTP
  // ══════════════════════════════════════════

  /// يتحقق من صحة الرمز المُدخل
  OtpVerifyResult verifyOtp(String phoneNumber, String enteredOtp) {
    // ─── تحقق: هل يوجد رمز نشط؟ ───
    if (_currentOtp == null || _currentPhone == null || _expiresAt == null) {
      return OtpVerifyResult(
        success: false,
        error: OtpError.noActiveOtp,
        message: 'لا يوجد رمز تحقق نشط. أعد إرسال الرمز.',
      );
    }

    // ─── تحقق: هل الرقم يتطابق؟ ───
    if (phoneNumber != _currentPhone) {
      return OtpVerifyResult(
        success: false,
        error: OtpError.phoneMismatch,
        message: 'رقم الهاتف لا يتطابق مع الرقم المسجل.',
      );
    }

    // ─── تحقق: هل انتهت الصلاحية؟ ───
    if (DateTime.now().isAfter(_expiresAt!)) {
      _invalidate();
      return OtpVerifyResult(
        success: false,
        error: OtpError.expired,
        message: 'انتهت صلاحية الرمز. أعد إرسال رمز جديد.',
      );
    }

    // ─── تحقق: هل تجاوز الحد الأقصى للمحاولات؟ ───
    if (_attempts >= maxAttempts) {
      _invalidate();
      return OtpVerifyResult(
        success: false,
        error: OtpError.maxAttempts,
        message: 'تجاوزت الحد الأقصى للمحاولات ($maxAttempts). أعد إرسال رمز جديد.',
      );
    }

    _attempts++;

    // ─── تحقق: هل الرمز صحيح؟ ───
    if (enteredOtp != _currentOtp) {
      final remaining = maxAttempts - _attempts;
      return OtpVerifyResult(
        success: false,
        error: OtpError.wrongCode,
        message: 'الرمز غير صحيح. متبقي $remaining محاولات.',
        remainingAttempts: remaining,
      );
    }

    // ─── نجاح! ───
    _invalidate(); // استخدام مرة واحدة فقط
    return OtpVerifyResult(
      success: true,
      message: 'تم التحقق بنجاح!',
    );
  }

  // ══════════════════════════════════════════
  //  إعادة إرسال OTP
  // ══════════════════════════════════════════

  /// يولّد رمز جديد لنفس الرقم
  OtpResult resendOtp() {
    if (_currentPhone == null) {
      return OtpResult(
        success: false,
        message: 'لا يوجد رقم هاتف مسجل.',
      );
    }
    return generateOtp(_currentPhone!);
  }

  // ══════════════════════════════════════════
  //  معلومات الحالة
  // ══════════════════════════════════════════

  /// هل يوجد رمز نشط غير منتهي الصلاحية؟
  bool get hasActiveOtp =>
      _currentOtp != null &&
      _expiresAt != null &&
      DateTime.now().isBefore(_expiresAt!);

  /// الوقت المتبقي بالثواني
  int get remainingSeconds {
    if (_expiresAt == null) return 0;
    final diff = _expiresAt!.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  /// عدد المحاولات المتبقية
  int get remainingAttempts => maxAttempts - _attempts;

  /// إبطال الرمز الحالي
  void _invalidate() {
    _currentOtp = null;
    _expiresAt = null;
    _attempts = 0;
  }

  /// إعادة تعيين كامل
  void reset() {
    _currentOtp = null;
    _currentPhone = null;
    _expiresAt = null;
    _attempts = 0;
  }
}

// ══════════════════════════════════════════
//  نماذج النتائج
// ══════════════════════════════════════════

class OtpResult {
  final bool success;
  final String? otp;
  final String? phone;
  final DateTime? expiresAt;
  final String message;

  OtpResult({
    required this.success,
    this.otp,
    this.phone,
    this.expiresAt,
    required this.message,
  });
}

class OtpVerifyResult {
  final bool success;
  final OtpError? error;
  final String message;
  final int? remainingAttempts;

  OtpVerifyResult({
    required this.success,
    this.error,
    required this.message,
    this.remainingAttempts,
  });
}

enum OtpError {
  noActiveOtp,
  phoneMismatch,
  expired,
  maxAttempts,
  wrongCode,
}
