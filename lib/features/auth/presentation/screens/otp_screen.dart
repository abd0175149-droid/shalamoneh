import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shalmoneh_app/core/theme/app_colors.dart';
import 'package:shalmoneh_app/core/constants/app_sizes.dart';
import 'package:shalmoneh_app/features/auth/providers/auth_provider.dart';
import 'package:shalmoneh_app/shared_widgets/yellow_button.dart';

/// شاشة التحقق OTP — 6 حقول + Firebase Phone Auth
class OtpScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final VoidCallback onVerified;
  final VoidCallback onBack;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
    required this.onVerified,
    required this.onBack,
  });

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  int _resendSeconds = 60;
  Timer? _timer;
  bool _canResend = false;
  String? _errorMessage;
  late String _currentVerificationId;

  @override
  void initState() {
    super.initState();
    _currentVerificationId = widget.verificationId;
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

  /// ─── التحقق عبر Firebase → Backend JWT ───
  Future<void> _verifyOTP() async {
    if (_isLoading) return;

    final enteredCode = _enteredOTP;
    if (enteredCode.length != 6) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ref.read(authProvider.notifier).verifyOtp(
        _currentVerificationId,
        enteredCode,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result.success) {
        _showSuccessAndNavigate();
      } else {
        setState(() => _errorMessage = result.message);
        _clearFields();
        HapticFeedback.heavyImpact();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'رمز التحقق غير صحيح';
      });
      _clearFields();
    }
  }

  void _clearFields() {
    for (var c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
  }

  void _showSuccessAndNavigate() async {
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

    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      widget.onVerified();
    }
  }

  /// ─── إعادة إرسال OTP عبر Firebase ───
  void _resendOTP() async {
    if (!_canResend) return;

    try {
      await ref.read(authProvider.notifier).sendOtp(
        phone: widget.phoneNumber,
        onCodeSent: (verificationId) {
          if (!mounted) return;
          // تحديث verificationId الجديد
          setState(() {
            _currentVerificationId = verificationId;
            _errorMessage = null;
          });
          _startTimer();
          _clearFields();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.sms_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '📩 تم إرسال رمز جديد',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF2E7D32),
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        },
        onError: (error) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ في إعادة الإرسال: $error'),
              backgroundColor: AppColors.error,
            ),
          );
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في إعادة الإرسال: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
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
