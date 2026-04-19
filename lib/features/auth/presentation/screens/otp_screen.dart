import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shalmoneh_app/core/theme/app_colors.dart';
import 'package:shalmoneh_app/core/constants/app_sizes.dart';
import 'package:shalmoneh_app/core/services/otp_service.dart';
import 'package:shalmoneh_app/shared_widgets/yellow_button.dart';

/// شاشة التحقق OTP — 6 حقول + تحقق حقيقي + مؤقت + إعادة إرسال
class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final VoidCallback onVerified;
  final VoidCallback onBack;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.onVerified,
    required this.onBack,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  int _resendSeconds = 60;
  Timer? _timer;
  bool _canResend = false;
  String? _errorMessage;
  int? _remainingAttempts;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  void _startTimer() {
    _resendSeconds = 60;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _resendSeconds--;
        if (_resendSeconds <= 0) {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _enteredOTP => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    // مسح رسالة الخطأ عند البدء بالكتابة
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }

    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // تحقق تلقائي عند إكمال 6 أرقام
    if (_enteredOTP.length == 6) {
      _verifyOTP();
    }
  }

  Future<void> _verifyOTP() async {
    if (_isLoading) return;

    final enteredCode = _enteredOTP;
    if (enteredCode.length != 6) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // محاكاة وقت الشبكة
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    // ─── التحقق الحقيقي عبر OtpService ───
    final result = OtpService.instance.verifyOtp(
      widget.phoneNumber,
      enteredCode,
    );

    setState(() => _isLoading = false);

    if (result.success) {
      // ✅ نجاح — أنيميشن ثم انتقال
      _showSuccessAndNavigate();
    } else {
      // ❌ فشل — عرض الخطأ
      setState(() {
        _errorMessage = result.message;
        _remainingAttempts = result.remainingAttempts;
      });

      // مسح الحقول وإعادة التركيز
      _clearFields();

      // اهتزاز (vibration) عند الخطأ
      HapticFeedback.heavyImpact();

      // إذا انتهت المحاولات أو الصلاحية → إعادة إرسال تلقائية
      if (result.error == OtpError.maxAttempts ||
          result.error == OtpError.expired ||
          result.error == OtpError.noActiveOtp) {
        setState(() => _canResend = true);
      }
    }
  }

  void _clearFields() {
    for (var c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
  }

  void _showSuccessAndNavigate() async {
    // عرض رسالة نجاح
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'تم التحقق بنجاح! ✨',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }

    // انتظار لرؤية الرسالة ثم الانتقال
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      widget.onVerified();
    }
  }

  void _resendOTP() {
    if (!_canResend) return;

    // ─── إعادة توليد OTP عبر الخدمة ───
    final result = OtpService.instance.resendOtp();

    if (result.success) {
      _startTimer();
      _clearFields();
      setState(() {
        _errorMessage = null;
        _remainingAttempts = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.sms_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '🔐 الرمز الجديد: ${result.otp}  (للتطوير)',
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingLG),
          child: Column(
            children: [
              const SizedBox(height: AppSizes.paddingXL),

              // ─── أيقونة ───
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sms_rounded,
                  size: 40,
                  color: AppColors.primaryYellow,
                ),
              ),
              const SizedBox(height: AppSizes.paddingLG),

              // ─── العنوان ───
              Text(
                'رمز التحقق 🔐',
                style: theme.textTheme.displaySmall,
              ),
              const SizedBox(height: AppSizes.paddingSM),
              Text(
                'تم إرسال رمز مكون من 6 أرقام إلى',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: AppSizes.paddingXS),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.phoneNumber,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                    textDirection: TextDirection.ltr,
                  ),
                  TextButton(
                    onPressed: widget.onBack,
                    child: const Text('تعديل'),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingXL),

              // ─── حقول OTP ───
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (index) {
                    return Container(
                      width: 48,
                      height: 56,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: TextFormField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          contentPadding: EdgeInsets.zero,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMD,
                            ),
                            borderSide: BorderSide(
                              color: _errorMessage != null
                                  ? AppColors.error
                                  : (_controllers[index].text.isNotEmpty
                                      ? AppColors.primaryYellow
                                      : (isDark
                                          ? AppColors.darkInputBorder
                                          : AppColors.lightInputBorder)),
                              width: _controllers[index].text.isNotEmpty ||
                                      _errorMessage != null
                                  ? 2
                                  : 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMD,
                            ),
                            borderSide: BorderSide(
                              color: _errorMessage != null
                                  ? AppColors.error
                                  : AppColors.primaryYellow,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: isDark
                              ? AppColors.darkInputFill
                              : AppColors.lightInputFill,
                        ),
                        onChanged: (value) => _onDigitChanged(index, value),
                      ),
                    );
                  }),
                ),
              ),

              // ─── رسالة الخطأ ───
              if (_errorMessage != null) ...[
                const SizedBox(height: AppSizes.paddingMD),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingMD,
                    vertical: AppSizes.paddingSM,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // ─── معلومات المحاولات المتبقية ───
              if (_remainingAttempts != null && _remainingAttempts! > 0) ...[
                const SizedBox(height: AppSizes.paddingSM),
                Text(
                  'المحاولات المتبقية: $_remainingAttempts من ${OtpService.maxAttempts}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _remainingAttempts! <= 2
                        ? AppColors.error
                        : AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              const SizedBox(height: AppSizes.paddingXL),

              // ─── زر التحقق ───
              if (_isLoading)
                const CircularProgressIndicator(
                  color: AppColors.primaryYellow,
                )
              else
                YellowButton(
                  text: 'تحقق',
                  onPressed: _enteredOTP.length == 6 ? _verifyOTP : null,
                ),

              const SizedBox(height: AppSizes.paddingLG),

              // ─── مؤقت إعادة الإرسال ───
              if (_canResend)
                TextButton(
                  onPressed: _resendOTP,
                  child: const Text(
                    'إعادة إرسال الرمز',
                    style: TextStyle(
                      color: AppColors.primaryYellow,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'إعادة الإرسال بعد ',
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      '00:${_resendSeconds.toString().padLeft(2, '0')}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppColors.primaryYellow,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
