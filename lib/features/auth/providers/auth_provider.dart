import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shalmoneh_app/core/services/auth_service.dart';
import 'package:shalmoneh_app/features/auth/data/models/user_model.dart';

/// حالات المصادقة
enum AuthStatus { loading, unauthenticated, authenticated, newUser }

/// State
class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.loading,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({AuthStatus? status, UserModel? user, String? errorMessage}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

/// Provider
final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _initialize();
    return const AuthState(status: AuthStatus.loading);
  }

  Future<void> _initialize() async {
    final isLoggedIn = await AuthService.instance.initialize();
    if (isLoggedIn) {
      state = AuthState(
        status: AuthStatus.authenticated,
        user: AuthService.instance.currentUser,
      );
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// إرسال OTP عبر Firebase
  Future<void> sendOtp({
    required String phone,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
    void Function(PhoneAuthCredential credential)? onAutoVerified,
  }) async {
    await AuthService.instance.sendOtp(
      phone: phone,
      onCodeSent: onCodeSent,
      onError: onError,
      onAutoVerified: onAutoVerified,
    );
  }

  /// التحقق من OTP عبر Firebase → ثم Backend JWT
  Future<AuthResult> verifyOtp(String verificationId, String otp) async {
    final result = await AuthService.instance.verifyOtpWithFirebase(verificationId, otp);
    if (result.success) {
      state = AuthState(
        status: result.isNewUser ? AuthStatus.newUser : AuthStatus.authenticated,
        user: result.user,
      );
    } else {
      state = state.copyWith(errorMessage: result.message);
    }
    return result;
  }

  /// التحقق التلقائي (Android) عبر Firebase
  Future<AuthResult> autoVerify(PhoneAuthCredential credential) async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await AuthService.instance.autoVerifyWithFirebase(credential);
    if (result.success) {
      state = AuthState(
        status: result.isNewUser ? AuthStatus.newUser : AuthStatus.authenticated,
        user: result.user,
      );
    } else {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: result.message,
      );
    }
    return result;
  }

  /// تسجيل Google (يرسل id_token مباشرة)
  Future<AuthResult> signInWithGoogle(String idToken) async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await AuthService.instance.signInWithGoogle(idToken);
    if (result.success) {
      state = AuthState(
        status: result.isNewUser ? AuthStatus.newUser : AuthStatus.authenticated,
        user: result.user,
      );
    } else {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: result.message,
      );
    }
    return result;
  }

  /// تحديث البروفايل
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    final success = await AuthService.instance.updateProfile(data);
    if (success) {
      state = AuthState(
        status: AuthStatus.authenticated,
        user: AuthService.instance.currentUser,
      );
    }
    return success;
  }

  /// تسجيل خروج
  Future<void> logout() async {
    await AuthService.instance.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// تأكيد إكمال البروفايل
  void confirmProfileComplete() {
    state = state.copyWith(status: AuthStatus.authenticated);
  }
}
