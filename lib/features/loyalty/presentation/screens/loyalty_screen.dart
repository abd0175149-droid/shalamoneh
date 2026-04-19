import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shalmoneh_app/core/theme/app_colors.dart';
import 'package:shalmoneh_app/core/constants/app_sizes.dart';
import 'package:shalmoneh_app/features/loyalty/providers/loyalty_provider.dart';

/// شاشة الولاء — QR + شريط تقدم + سجل المعاملات + مستويات
class LoyaltyScreen extends ConsumerWidget {
  const LoyaltyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loyalty = ref.watch(loyaltyProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('شلموناتي ⭐', style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
        )),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        child: Column(
          children: [
            // ─── بطاقة QR ───
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.paddingLG),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryYellow.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // QR Code placeholder
                  Container(
                    width: 180, height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code_2_rounded, size: 100,
                              color: AppColors.darkBackground),
                          const SizedBox(height: 4),
                          Text('QR-SH-2024',
                              style: TextStyle(color: AppColors.darkBackground,
                                  fontSize: 12, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingMD),
                  Text('امسح الكود عند الكاشير', style: TextStyle(
                    color: AppColors.onPrimary.withValues(alpha: 0.8),
                    fontSize: 14,
                  )),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.paddingLG),

            // ─── شريط التقدم ───
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.paddingMD),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(AppSizes.radiusLG),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${loyalty.currentPoints}', style: theme.textTheme.displaySmall?.copyWith(
                        color: AppColors.primaryYellow, fontWeight: FontWeight.w800,
                      )),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryYellow.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                        ),
                        child: Text('⭐ ${loyalty.level}', style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.primaryYellow, fontWeight: FontWeight.w700,
                        )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('شلمونة', style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  )),
                  const SizedBox(height: AppSizes.paddingSM),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: loyalty.progress,
                      minHeight: 12,
                      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryYellow),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('${loyalty.pointsToNextLevel} شلمونة للمشروب المجاني! 🎁',
                      style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.paddingSM),

            // ─── إحصائيات ───
            Row(
              children: [
                _StatTile(label: 'مكتسبة', value: '${loyalty.totalEarned}',
                    icon: Icons.arrow_upward_rounded, color: AppColors.success,
                    isDark: isDark, theme: theme),
                const SizedBox(width: AppSizes.paddingSM),
                _StatTile(label: 'مستبدلة', value: '${loyalty.totalRedeemed}',
                    icon: Icons.arrow_downward_rounded, color: AppColors.warning,
                    isDark: isDark, theme: theme),
              ],
            ),
            const SizedBox(height: AppSizes.paddingLG),

            // ─── سجل المعاملات ───
            Row(
              children: [
                Text('سجل النقاط', style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                )),
                const Spacer(),
                Text('${loyalty.transactions.length} معاملة',
                    style: theme.textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: AppSizes.paddingSM),

            ...loyalty.transactions.map((tx) => Container(
              margin: const EdgeInsets.only(bottom: AppSizes.paddingSM),
              padding: const EdgeInsets.all(AppSizes.paddingMD),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: tx.isEarned
                          ? AppColors.success.withValues(alpha: 0.12)
                          : AppColors.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      tx.isEarned ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                      color: tx.isEarned ? AppColors.success : AppColors.warning,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingSM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tx.description, style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        )),
                        const SizedBox(height: 2),
                        Text(_formatDate(tx.date), style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
                        )),
                      ],
                    ),
                  ),
                  Text(
                    '${tx.isEarned ? '+' : '-'}${tx.points}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: tx.isEarned ? AppColors.success : AppColors.warning,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: AppSizes.paddingLG),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inHours < 1) return 'الآن';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;
  final ThemeData theme;

  const _StatTile({
    required this.label, required this.value,
    required this.icon, required this.color,
    required this.isDark, required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                )),
                Text(label, style: theme.textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
