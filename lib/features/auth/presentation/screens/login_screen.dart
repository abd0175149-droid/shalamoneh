import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:js' as js;
import 'dart:js_util' show promiseToFuture;
import 'package:shalmoneh_app/core/theme/app_colors.dart';
import 'package:shalmoneh_app/core/constants/app_sizes.dart';
import 'package:shalmoneh_app/features/auth/providers/auth_provider.dart';
import 'package:shalmoneh_app/shared_widgets/yellow_button.dart';

/// شاشة تسجيل الدخول — OTP + Google Sign-In
class LoginScreen extends ConsumerStatefulWidget {
  final void Function(String fullPhone, String countryCode, String otp) onSendOTP;

  const LoginScreen({super.key, required this.onSendOTP});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  final _countries = [
    {'code': '+962', 'flag': '🇯🇴', 'name': 'الأردن', 'digits': 9},
    {'code': '+966', 'flag': '🇸🇦', 'name': 'السعودية', 'digits': 9},
    {'code': '+964', 'flag': '🇮🇶', 'name': 'العراق', 'digits': 10},
    {'code': '+970', 'flag': '🇵🇸', 'name': 'فلسطين', 'digits': 9},
  ];
  late Map<String, Object> _selectedCountry;

  @override
  void initState() {
    super.initState();
    _selectedCountry = _countries[0];
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  /// ─── إرسال OTP عبر API ───
  Future<void> _handleSendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final fullPhone =
        '${_selectedCountry['code']}${_phoneController.text.trim()}';

    try {
      // إرسال OTP عبر Backend API
      final result = await ref.read(authProvider.notifier).sendOtp(fullPhone);

      if (!mounted) return;
      setState(() => _isLoading = false);

      // في وضع التطوير: عرض OTP
      final devOtp = result['otp'] as String?;
      if (devOtp != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.sms_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '🔐 رمز التحقق: $devOtp  (للتطوير فقط)',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF2E7D32),
            duration: const Duration(seconds: 10),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }

      widget.onSendOTP(fullPhone, _selectedCountry['code'] as String, devOtp ?? '');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في الاتصال: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  /// ─── تسجيل Google Sign-In عبر GIS One Tap (داخل الصفحة) ───
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);

    try {
      // استدعاء GIS One Tap عبر JavaScript (يعرض overlay داخل الصفحة)
      final idToken = await _callGoogleOneTap();

      if (idToken == null) {
        if (mounted) setState(() => _isGoogleLoading = false);
        return;
      }

      // إرسال idToken للـ Backend
      final result = await ref.read(authProvider.notifier).signInWithGoogle(idToken);

      if (!mounted) return;
      setState(() => _isGoogleLoading = false);

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isGoogleLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في Google: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  /// استدعاء triggerGoogleSignIn() المعرّفة في index.html
  Future<String?> _callGoogleOneTap() async {
    if (!kIsWeb) return null;

    try {
      // تحقق أن الدالة موجودة
      final hasFunc = js.context.hasProperty('triggerGoogleSignIn');
      if (!hasFunc) {
        debugPrint('triggerGoogleSignIn not found in window');
        throw Exception('Google Sign-In غير متاح حالياً. حاول مرة أخرى.');
      }

      // استدعاء JS function
      final result = js.context.callMethod('triggerGoogleSignIn', []);

      if (result == null) {
        throw Exception('Google Sign-In لم يعمل. تأكد من تحميل الصفحة كاملة.');
      }

      // تحويل JS Promise لـ Dart Future
      final credential = await promiseToFuture<String>(result);
      return credential;
    } catch (e) {
      debugPrint('Google One Tap error: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingLG),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSizes.paddingXXL),

                // ─── العنوان ───
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primaryYellow.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.phone_android_rounded,
                      size: 40,
                      color: AppColors.primaryYellow,
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingLG),
                Center(
                  child: Text(
                    'تسجيل الدخول 📱',
                    style: theme.textTheme.displaySmall,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingSM),
                Center(
                  child: Text(
                    'أدخل رقم هاتفك وسنرسل لك رمز التحقق',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingXL),

                // ─── اختيار الدولة ───
                Text('الدولة', style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSizes.paddingSM),
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppSizes.paddingSM),
                    itemCount: _countries.length,
                    itemBuilder: (context, index) {
                      final country = _countries[index];
                      final isSelected =
                          country['code'] == _selectedCountry['code'];

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCountry = country;
                            _phoneController.clear();
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingMD,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryYellow
                                : (isDark
                                    ? AppColors.darkCard
                                    : AppColors.lightCard),
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusFull),
                            border: isSelected
                                ? null
                                : Border.all(
                                    color: isDark
                                        ? AppColors.darkDivider
                                        : AppColors.lightDivider,
                                  ),
                          ),
                          child: Center(
                            child: Text(
                              '${country['flag']} ${country['name']}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: isSelected ? AppColors.onPrimary : null,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSizes.paddingMD),

                // ─── حقل رقم الهاتف ───
                Text('رقم الهاتف', style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSizes.paddingSM),
                Row(
                  children: [
                    Container(
                      height: AppSizes.inputHeight,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingMD,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkInputFill
                            : AppColors.lightInputFill,
                        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkInputBorder
                              : AppColors.lightInputBorder,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${_selectedCountry['flag']} ${_selectedCountry['code']}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingSM),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(
                            _selectedCountry['digits'] as int,
                          ),
                        ],
                        textDirection: TextDirection.ltr,
                        style: theme.textTheme.titleMedium?.copyWith(
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: '7XXXXXXXX',
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? AppColors.darkTextHint
                                : AppColors.lightTextHint,
                            letterSpacing: 1.5,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'أدخل رقم الهاتف';
                          }
                          if (value.length <
                              (_selectedCountry['digits'] as int) - 1) {
                            return 'رقم الهاتف غير صحيح';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.paddingXL),

                // ─── زر إرسال OTP ───
                YellowButton(
                  text: _isLoading ? 'جاري الإرسال...' : 'متابعة',
                  icon: _isLoading ? null : Icons.arrow_back_rounded,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _handleSendOTP,
                ),

                const SizedBox(height: AppSizes.paddingLG),

                // ─── فاصل "أو" ───
                Row(
                  children: [
                    Expanded(child: Divider(
                      color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                    )),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
                      child: Text('أو', style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      )),
                    ),
                    Expanded(child: Divider(
                      color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                    )),
                  ],
                ),

                const SizedBox(height: AppSizes.paddingLG),

                // ─── زر Google Sign-In ───
                GestureDetector(
                  onTap: _isGoogleLoading ? null : _handleGoogleSignIn,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    height: AppSizes.buttonHeight,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                      border: Border.all(
                        color: isDark ? AppColors.darkDivider : const Color(0xFFDDDDDD),
                        width: 1.5,
                      ),
                      boxShadow: isDark ? [] : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _isGoogleLoading
                        ? const Center(child: SizedBox(
                            width: 24, height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Google "G" Logo
                              Container(
                                width: 24, height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Center(
                                  child: Text('G', style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF4285F4),
                                    fontFamily: 'Roboto',
                                  )),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'المتابعة عبر Google',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: AppSizes.paddingXL),

                // ─── شروط الاستخدام ───
                Center(
                  child: Text.rich(
                    TextSpan(
                      text: 'بالمتابعة أنت توافق على ',
                      style: theme.textTheme.bodySmall,
                      children: [
                        TextSpan(
                          text: 'شروط الاستخدام',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.primaryYellow,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(text: ' و'),
                        TextSpan(
                          text: 'سياسة الخصوصية',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.primaryYellow,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
