import 'package:firebase_auth/firebase_auth.dart';

/// خدمة التحقق من رقم الهاتف عبر Firebase
/// Firebase يدير: إرسال SMS + التحقق + rate limiting + anti-abuse
class FirebasePhoneAuthService {
  static final instance = FirebasePhoneAuthService._();
  FirebasePhoneAuthService._();

  final _auth = FirebaseAuth.instance;

  /// إرسال OTP — Firebase يرسل SMS حقيقي
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
    required void Function(PhoneAuthCredential credential) onAutoVerified,
    int? resendToken,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber, // مثال: +962799999999
      timeout: const Duration(seconds: 60),

      // ✅ Android فقط: تحقق تلقائي (بدون إدخال يدوي)
      verificationCompleted: onAutoVerified,

      // ❌ فشل (رقم غلط، rate limit، إلخ)
      verificationFailed: (FirebaseAuthException e) {
        onError(_translateError(e.code));
      },

      // 📩 تم إرسال SMS — نعطي verificationId لشاشة OTP
      codeSent: (String verificationId, int? forceResendToken) {
        onCodeSent(verificationId);
      },

      // ⏰ انتهى وقت الاسترجاع التلقائي
      codeAutoRetrievalTimeout: (_) {},

      forceResendingToken: resendToken,
    );
  }

  /// التحقق اليدوي من OTP → يرجع Firebase ID Token
  Future<String?> verifyOtp(String verificationId, String smsCode) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    final userCredential = await _auth.signInWithCredential(credential);

    // الحصول على Firebase ID Token لإرساله للـ Backend
    return await userCredential.user?.getIdToken();
  }

  /// التحقق التلقائي (Android) → يرجع Firebase ID Token
  Future<String?> autoVerify(PhoneAuthCredential credential) async {
    final userCredential = await _auth.signInWithCredential(credential);
    return await userCredential.user?.getIdToken();
  }

  /// ترجمة أخطاء Firebase للعربية
  String _translateError(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return 'رقم الهاتف غير صحيح';
      case 'too-many-requests':
        return 'محاولات كثيرة. حاول لاحقاً';
      case 'quota-exceeded':
        return 'تم تجاوز الحد المسموح';
      case 'network-request-failed':
        return 'تحقق من اتصال الإنترنت';
      case 'invalid-verification-code':
        return 'رمز التحقق غير صحيح';
      case 'session-expired':
        return 'انتهت صلاحية الرمز. أعد الإرسال';
      default:
        return 'خطأ في التحقق: $code';
    }
  }
}
