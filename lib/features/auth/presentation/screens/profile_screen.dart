import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shalmoneh_app/core/theme/app_colors.dart';
import 'package:shalmoneh_app/core/constants/app_sizes.dart';
import 'package:shalmoneh_app/core/theme/theme_provider.dart';
import 'package:shalmoneh_app/features/auth/providers/auth_provider.dart';
import 'package:shalmoneh_app/features/auth/presentation/screens/our_story_screen.dart';
import 'package:shalmoneh_app/features/auth/presentation/screens/privacy_policy_screen.dart';
import 'package:shalmoneh_app/features/loyalty/providers/loyalty_provider.dart';
import 'package:shalmoneh_app/features/menu/presentation/screens/order_history_screen.dart';
import 'package:shalmoneh_app/features/menu/presentation/screens/favorites_screen.dart';

/// شاشة الملف الشخصي — بيانات المستخدم الحقيقية + إعدادات + قصة شلمونة
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeNotifier = ref.read(themeModeProvider.notifier);
    final loyalty = ref.watch(loyaltyProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingMD),
          child: Column(
            children: [
              const SizedBox(height: AppSizes.paddingMD),

              // ─── صورة المستخدم ───
              CircleAvatar(
                radius: 45,
                backgroundColor: AppColors.primaryYellow.withValues(alpha: 0.15),
                backgroundImage: user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                    ? NetworkImage(user.avatarUrl!)
                    : null,
                child: user?.avatarUrl == null || user!.avatarUrl!.isEmpty
                    ? const Icon(Icons.person_rounded, size: 45, color: AppColors.primaryYellow)
                    : null,
              ),
              const SizedBox(height: AppSizes.paddingSM),
              Text(
                user?.name ?? 'مستخدم شلمونة',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                user?.phone ?? user?.email ?? '',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
                textDirection: TextDirection.ltr,
              ),
              const SizedBox(height: AppSizes.paddingSM),

              // ─── شارة المستوى ───
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMD, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: AppColors.primaryYellow, size: 18),
                    const SizedBox(width: 4),
                    Text('${loyalty.level} • ${loyalty.currentPoints} نقطة', style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.primaryYellow, fontWeight: FontWeight.w700,
                    )),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.paddingXL),

              // ─── الخيارات ───
              _ProfileOption(
                icon: Icons.edit_rounded,
                title: 'تعديل البيانات الشخصية',
                isDark: isDark, theme: theme,
                onTap: () => _showEditProfileSheet(context, theme, isDark, ref),
              ),
              _ProfileOption(
                icon: Icons.receipt_long_rounded,
                title: 'تاريخ الطلبات',
                isDark: isDark, theme: theme,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const Directionality(
                      textDirection: TextDirection.rtl,
                      child: OrderHistoryScreen(),
                    ),
                  ));
                },
              ),
              _ProfileOption(
                icon: Icons.favorite_rounded,
                title: 'المشروبات المفضلة',
                isDark: isDark, theme: theme,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const Directionality(
                      textDirection: TextDirection.rtl,
                      child: FavoritesScreen(),
                    ),
                  ));
                },
              ),

              const SizedBox(height: AppSizes.paddingSM),
              Divider(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
              const SizedBox(height: AppSizes.paddingSM),

              // ─── تبديل الثيم ───
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMD, vertical: AppSizes.paddingSM,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                ),
                child: Row(
                  children: [
                    Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        color: AppColors.primaryYellow),
                    const SizedBox(width: AppSizes.paddingMD),
                    Expanded(
                      child: Text('الوضع الداكن', style: theme.textTheme.bodyLarge),
                    ),
                    Switch.adaptive(
                      value: isDark,
                      activeColor: AppColors.primaryYellow,
                      onChanged: (_) => themeNotifier.toggleTheme(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.paddingSM),

              // ─── قصة شلمونة ───
              _ProfileOption(
                icon: Icons.auto_stories_rounded,
                title: 'قصة شلمونة',
                isDark: isDark, theme: theme,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const Directionality(
                      textDirection: TextDirection.rtl,
                      child: OurStoryScreen(),
                    ),
                  ));
                },
              ),
              _ProfileOption(
                icon: Icons.privacy_tip_rounded,
                title: 'سياسة الخصوصية',
                isDark: isDark, theme: theme,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const Directionality(
                      textDirection: TextDirection.rtl,
                      child: PrivacyPolicyScreen(),
                    ),
                  ));
                },
              ),

              const SizedBox(height: AppSizes.paddingLG),

              // ─── تسجيل الخروج ───
              GestureDetector(
                onTap: () => _showLogoutDialog(context, ref),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMD),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Center(
                    child: Text(
                      'تسجيل الخروج',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.paddingMD),
              Text('الإصدار 1.0.0', style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
              )),
              const SizedBox(height: AppSizes.paddingMD),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════
  //  حوار تأكيد تسجيل الخروج
  // ════════════════════════════════════════════
  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تسجيل الخروج'),
          content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await ref.read(authProvider.notifier).logout();
                // سيتم إعادة التوجيه تلقائياً عبر AuthGate
              },
              child: const Text('تسجيل الخروج',
                  style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════
  //  BottomSheet تعديل البيانات الشخصية
  // ════════════════════════════════════════════
  void _showEditProfileSheet(BuildContext context, ThemeData theme, bool isDark, WidgetRef ref) {
    final user = ref.read(authProvider).user;
    final nameCtrl = TextEditingController(text: user?.name ?? '');
    final emailCtrl = TextEditingController(text: user?.email ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.only(
              left: AppSizes.paddingLG,
              right: AppSizes.paddingLG,
              top: AppSizes.paddingLG,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSizes.paddingLG,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingMD),
                Text('تعديل البيانات ✏️',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: AppSizes.paddingLG),

                // الاسم
                Text('الاسم', style: theme.textTheme.titleSmall),
                const SizedBox(height: 6),
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    hintText: 'أدخل اسمك',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingMD),

                // البريد
                Text('البريد الإلكتروني', style: theme.textTheme.titleSmall),
                const SizedBox(height: 6),
                TextFormField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textDirection: TextDirection.ltr,
                  decoration: const InputDecoration(
                    hintText: 'example@email.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingXL),

                // زر حفظ
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      final data = <String, dynamic>{};
                      if (nameCtrl.text.trim().isNotEmpty) {
                        data['name'] = nameCtrl.text.trim();
                      }
                      if (emailCtrl.text.trim().isNotEmpty) {
                        data['email'] = emailCtrl.text.trim();
                      }

                      if (data.isEmpty) {
                        Navigator.pop(ctx);
                        return;
                      }

                      final success = await ref.read(authProvider.notifier).updateProfile(data);

                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success ? 'تم حفظ التعديلات ✅' : 'حدث خطأ!'),
                            backgroundColor: success ? AppColors.success : AppColors.error,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                      ),
                    ),
                    child: const Text('حفظ التعديلات',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDark;
  final ThemeData theme;
  final VoidCallback onTap;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.isDark,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.paddingSM),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMD,
          vertical: AppSizes.paddingSM + 4,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryYellow, size: 22),
            const SizedBox(width: AppSizes.paddingMD),
            Expanded(child: Text(title, style: theme.textTheme.bodyLarge)),
            Icon(Icons.arrow_back_ios_new_rounded, size: 16,
                color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint),
          ],
        ),
      ),
    );
  }
}
