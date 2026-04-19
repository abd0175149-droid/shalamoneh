import 'package:flutter/material.dart';
import 'package:shalmoneh_app/core/theme/app_colors.dart';
import 'package:shalmoneh_app/core/constants/app_sizes.dart';

/// صفحة سياسة الخصوصية
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('سياسة الخصوصية'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان
            Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.privacy_tip_rounded,
                    size: 30, color: AppColors.primaryYellow),
              ),
            ),
            const SizedBox(height: AppSizes.paddingMD),
            Center(
              child: Text('سياسة الخصوصية',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                'آخر تحديث: أبريل 2026',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppColors.darkTextHint
                      : AppColors.lightTextHint,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.paddingXL),

            _buildSection(
              theme: theme,
              isDark: isDark,
              icon: Icons.info_outline_rounded,
              title: 'مقدمة',
              content:
                  'نحن في شلمونة نقدّر خصوصيتك ونلتزم بحماية بياناتك الشخصية. '
                  'توضح هذه السياسة كيف نجمع ونستخدم ونحمي معلوماتك عند استخدام تطبيقنا.',
            ),
            _buildSection(
              theme: theme,
              isDark: isDark,
              icon: Icons.data_usage_rounded,
              title: 'البيانات التي نجمعها',
              content:
                  '• رقم الهاتف (للتسجيل والتحقق)\n'
                  '• الاسم والبريد الإلكتروني (اختياري)\n'
                  '• تاريخ الميلاد (لمكافأة عيد الميلاد)\n'
                  '• سجل الطلبات والمفضلات\n'
                  '• الموقع الجغرافي (لعرض أقرب فرع)',
            ),
            _buildSection(
              theme: theme,
              isDark: isDark,
              icon: Icons.settings_rounded,
              title: 'كيف نستخدم بياناتك',
              content:
                  '• إدارة حسابك وتخصيص تجربتك\n'
                  '• معالجة طلباتك وإرسال التحديثات\n'
                  '• احتساب نقاط الولاء والمكافآت\n'
                  '• تحسين خدماتنا وتطبيقنا\n'
                  '• إرسال العروض والتنبيهات (بإذنك)',
            ),
            _buildSection(
              theme: theme,
              isDark: isDark,
              icon: Icons.shield_rounded,
              title: 'حماية البيانات',
              content:
                  '• نستخدم تشفير SSL لحماية البيانات أثناء النقل\n'
                  '• لا نشارك بياناتك مع أطراف ثالثة دون إذنك\n'
                  '• نخزّن البيانات في خوادم آمنة محمية\n'
                  '• نحتفظ ببياناتك فقط طالما كان حسابك نشطاً',
            ),
            _buildSection(
              theme: theme,
              isDark: isDark,
              icon: Icons.person_rounded,
              title: 'حقوقك',
              content:
                  '• طلب نسخة من بياناتك الشخصية\n'
                  '• تعديل أو تصحيح بياناتك\n'
                  '• حذف حسابك وبياناتك بالكامل\n'
                  '• إلغاء الاشتراك في الإشعارات التسويقية',
            ),
            _buildSection(
              theme: theme,
              isDark: isDark,
              icon: Icons.email_rounded,
              title: 'تواصل معنا',
              content:
                  'لأي استفسارات حول الخصوصية:\n'
                  '• البريد: privacy@shalmoneh.com\n'
                  '• الهاتف: +962-6-XXXXXXX\n'
                  '• العنوان: عمان، الأردن',
            ),

            const SizedBox(height: AppSizes.paddingXL),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required ThemeData theme,
    required bool isDark,
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMD),
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryYellow, size: 22),
              const SizedBox(width: AppSizes.paddingSM),
              Text(title,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: AppSizes.paddingSM),
          Text(content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                height: 1.7,
              )),
        ],
      ),
    );
  }
}
