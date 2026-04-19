import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shalmoneh_app/core/network/api_client.dart';
import 'package:shalmoneh_app/core/network/api_endpoints.dart';
import 'package:shalmoneh_app/core/services/firebase_phone_auth_service.dart';
import 'package:shalmoneh_app/features/auth/data/models/user_model.dart';

/// خدمة المصادقة المركزية
/// تدير: Token storage, API calls, User session, Auto-login
/// تدعم: Firebase Phone Auth + Google Sign-In
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userDataKey = 'user_data';

  String? _accessToken;
  String? _refreshToken;
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _accessToken != null && _currentUser != null;
  String? get accessToken => _accessToken;

  // ══════════════════════════════════════════
  //  التهيئة — تحميل من التخزين المحلي
  // ══════════════════════════════════════════

  Future<bool> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_accessTokenKey);
    _refreshToken = prefs.getString(_refreshTokenKey);

    if (_accessToken != null) {
      apiClient.setToken(_accessToken!);

      // محاولة تحميل بيانات المستخدم المحفوظة
      final userData = prefs.getString(_userDataKey);
      if (userData != null) {
        try {
          _currentUser = UserModel.fromJson(jsonDecode(userData));
        } catch (_) {}
      }

      // تحقق من صلاحية Token عبر API
      try {
        final response = await apiClient.get(ApiEndpoints.profile);
        if (response.success && response.data != null) {
          _currentUser = UserModel.fromJson(response.data as Map<String, dynamic>);
          await _saveUserLocally();
          return true;
        }
      } catch (_) {
        // Token منتهي — حاول تجديده
        if (_refreshToken != null) {
          return await _tryRefreshToken();
        }
      }
    }
    return false;
  }

  // ══════════════════════════════════════════
  //  Firebase Phone Auth (OTP)
  // ══════════════════════════════════════════

  /// إرسال OTP عبر Firebase — يرسل SMS حقيقي
  Future<void> sendOtp({
    required String phone,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
    void Function(PhoneAuthCredential credential)? onAutoVerified,
  }) async {
    await FirebasePhoneAuthService.instance.sendOtp(
      phoneNumber: phone,
      onCodeSent: onCodeSent,
      onError: onError,
      onAutoVerified: onAutoVerified ?? (_) {},
    );
  }

  /// التحقق من OTP عبر Firebase → ثم إصدار JWT من Backend
  Future<AuthResult> verifyOtpWithFirebase(String verificationId, String otp) async {
    // 1. Firebase يتحقق من OTP → يعطينا Firebase ID Token
    final firebaseToken = await FirebasePhoneAuthService.instance.verifyOtp(
      verificationId,
      otp,
    );

    if (firebaseToken == null) {
      return AuthResult(success: false, message: 'فشل التحقق من الرمز');
    }

    // 2. إرسال Firebase Token للـ Backend → Backend يتحقق ويصدر JWT
    final response = await apiClient.post(
      ApiEndpoints.firebasePhone,
      body: {'firebase_token': firebaseToken},
    );

    if (response.success && response.data != null) {
      return await _handleAuthResponse(response.data as Map<String, dynamic>);
    }

    return AuthResult(success: false, message: response.message ?? 'خطأ في التحقق');
  }

  /// التحقق التلقائي (Android auto-verify) → ثم إصدار JWT
  Future<AuthResult> autoVerifyWithFirebase(PhoneAuthCredential credential) async {
    final firebaseToken = await FirebasePhoneAuthService.instance.autoVerify(credential);

    if (firebaseToken == null) {
      return AuthResult(success: false, message: 'فشل التحقق التلقائي');
    }

    final response = await apiClient.post(
      ApiEndpoints.firebasePhone,
      body: {'firebase_token': firebaseToken},
    );

    if (response.success && response.data != null) {
      return await _handleAuthResponse(response.data as Map<String, dynamic>);
    }

    return AuthResult(success: false, message: response.message ?? 'خطأ');
  }

  // ══════════════════════════════════════════
  //  Google Auth
  // ══════════════════════════════════════════

  /// تسجيل الدخول عبر Google — يرسل id_token من GIS One Tap
  Future<AuthResult> signInWithGoogle(String idToken) async {
    final response = await apiClient.post(
      ApiEndpoints.googleAuth,
      body: {'id_token': idToken},
    );

    if (response.success && response.data != null) {
      return await _handleAuthResponse(response.data as Map<String, dynamic>);
    }

    return AuthResult(success: false, message: response.message ?? 'خطأ في تسجيل Google');
  }

  // ══════════════════════════════════════════
  //  Profile
  // ══════════════════════════════════════════

  /// تحديث البروفايل
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    final response = await apiClient.put(
      ApiEndpoints.profile,
      body: data,
    );

    if (response.success && response.data != null) {
      _currentUser = UserModel.fromJson(response.data as Map<String, dynamic>);
      await _saveUserLocally();
      return true;
    }
    return false;
  }

  // ══════════════════════════════════════════
  //  Logout
  // ══════════════════════════════════════════

  Future<void> logout() async {
    try {
      await apiClient.post(ApiEndpoints.logout);
    } catch (_) {}

    _accessToken = null;
    _refreshToken = null;
    _currentUser = null;
    apiClient.clearToken();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userDataKey);
  }

  // ══════════════════════════════════════════
  //  Internal Helpers
  // ══════════════════════════════════════════

  Future<AuthResult> _handleAuthResponse(Map<String, dynamic> data) async {
    _accessToken = data['access_token'] as String?;
    _refreshToken = data['refresh_token'] as String?;
    final userData = data['user'] as Map<String, dynamic>?;
    final isNewUser = data['is_new_user'] as bool? ?? false;

    if (_accessToken != null) {
      apiClient.setToken(_accessToken!);
    }

    if (userData != null) {
      _currentUser = UserModel.fromJson(userData);
    }

    await _saveTokensLocally();
    await _saveUserLocally();

    return AuthResult(
      success: true,
      isNewUser: isNewUser,
      user: _currentUser,
      message: isNewUser ? 'تم إنشاء حسابك بنجاح' : 'مرحباً بعودتك',
    );
  }

  Future<bool> _tryRefreshToken() async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.refreshToken,
        body: {'refresh_token': _refreshToken},
      );

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        _accessToken = data['access_token'] as String?;
        _refreshToken = data['refresh_token'] as String?;

        if (_accessToken != null) {
          apiClient.setToken(_accessToken!);
          final userData = data['user'] as Map<String, dynamic>?;
          if (userData != null) {
            _currentUser = UserModel.fromJson(userData);
          }
          await _saveTokensLocally();
          await _saveUserLocally();
          return true;
        }
      }
    } catch (_) {}

    // فشل التجديد — مسح كل شيء
    await logout();
    return false;
  }

  Future<void> _saveTokensLocally() async {
    final prefs = await SharedPreferences.getInstance();
    if (_accessToken != null) {
      await prefs.setString(_accessTokenKey, _accessToken!);
    }
    if (_refreshToken != null) {
      await prefs.setString(_refreshTokenKey, _refreshToken!);
    }
  }

  Future<void> _saveUserLocally() async {
    if (_currentUser == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, jsonEncode(_currentUser!.toJson()));
  }
}

/// نتيجة عملية المصادقة
class AuthResult {
  final bool success;
  final bool isNewUser;
  final UserModel? user;
  final String message;

  AuthResult({
    required this.success,
    this.isNewUser = false,
    this.user,
    this.message = '',
  });
}
