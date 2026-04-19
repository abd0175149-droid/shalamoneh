import 'package:flutter/material.dart';
import 'package:shalmoneh_app/core/theme/app_colors.dart';
import 'package:shalmoneh_app/core/constants/app_sizes.dart';
import 'package:shalmoneh_app/shared_widgets/yellow_button.dart';

/// شاشة إكمال البروفايل — تظهر فقط للمستخدمين الجدد
class CompleteProfileScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  const CompleteProfileScreen({
    super.key,
    required this.onComplete,
    required this.onSkip,
  });

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  DateTime? _birthDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primaryYellow,
                  onPrimary: AppColors.onPrimary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  void _handleComplete() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال اسمك')),
      );
      return;
    }
    setState(() => _isLoading = true);
    // TODO: حفظ البيانات عبر API
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        widget.onComplete();
      }
    });
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── زر تخطي ───
              Align(
                alignment: Alignment.topLeft,
                child: TextButton(
                  onPressed: widget.onSkip,
                  child: Text(
                    'تخطي',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.paddingMD),

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
                    Icons.person_add_rounded,
                    size: 40,
                    color: AppColors.primaryYellow,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.paddingMD),
              Center(
                child: Text(
                  'أكمل بياناتك 📝',
                  style: theme.textTheme.displaySmall,
                ),
              ),
              const SizedBox(height: AppSizes.paddingSM),
              Center(
                child: Text(
                  'ساعدنا نعرفك أكثر لتجربة أفضل!',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.paddingXL),




              // ─── حقل الاسم ───
              Text('الاسم الكامل *', style: theme.textTheme.titleSmall),
              const SizedBox(height: AppSizes.paddingSM),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'مثال: أحمد محمد',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: AppSizes.paddingMD),

              // ─── حقل الإيميل ───
              Text('البريد الإلكتروني (اختياري)',
                  style: theme.textTheme.titleSmall),
              const SizedBox(height: AppSizes.paddingSM),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(
                  hintText: 'example@email.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: AppSizes.paddingMD),

              // ─── تاريخ الميلاد ───
              Text('تاريخ الميلاد (لمكافأة عيد ميلادك 🎂)',
                  style: theme.textTheme.titleSmall),
              const SizedBox(height: AppSizes.paddingSM),
              GestureDetector(
                onTap: _selectBirthDate,
                child: Container(
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
                  child: Row(
                    children: [
                      Icon(
                        Icons.cake_rounded,
                        color: isDark
                            ? AppColors.darkTextHint
                            : AppColors.lightTextHint,
                      ),
                      const SizedBox(width: AppSizes.paddingMD),
                      Text(
                        _birthDate == null
                            ? 'اختر تاريخ الميلاد'
                            : '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _birthDate == null
                              ? (isDark
                                  ? AppColors.darkTextHint
                                  : AppColors.lightTextHint)
                              : null,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_drop_down_rounded,
                        color: isDark
                            ? AppColors.darkTextHint
                            : AppColors.lightTextHint,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.paddingXL),

              // ─── زر إكمال ───
              YellowButton(
                text: 'إكمال التسجيل ✨',
                isLoading: _isLoading,
                onPressed: _handleComplete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
