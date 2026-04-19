import 'package:flutter/material.dart';
import 'package:shalmoneh_app/core/theme/app_colors.dart';
import 'package:shalmoneh_app/core/constants/app_sizes.dart';
import 'package:shalmoneh_app/features/menu/data/models/customization_model.dart';

/// شاشة تاريخ الطلبات — قائمة الطلبات السابقة مع إعادة الطلب
class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // بيانات Mock
    final orders = [
      _MockOrder(
        id: '#3847', date: DateTime.now().subtract(const Duration(hours: 3)),
        items: ['كوكتيل شلمونة', 'عصير برتقال'], total: 5.25,
        status: OrderStatus.completed, branch: 'فرع الشميساني',
      ),
      _MockOrder(
        id: '#3821', date: DateTime.now().subtract(const Duration(days: 1)),
        items: ['مانجو باشن', 'وافل شلمونة'], total: 6.75,
        status: OrderStatus.completed, branch: 'فرع عبدون',
      ),
      _MockOrder(
        id: '#3790', date: DateTime.now().subtract(const Duration(days: 3)),
        items: ['سحلب شلمونة'], total: 2.25,
        status: OrderStatus.completed, branch: 'فرع الجاردنز',
      ),
      _MockOrder(
        id: '#3756', date: DateTime.now().subtract(const Duration(days: 5)),
        items: ['بيري بلاست', 'شوكولاتة ساخنة', 'كنافة بالقشطة'], total: 9.50,
        status: OrderStatus.completed, branch: 'فرع الشميساني',
      ),
      _MockOrder(
        id: '#3701', date: DateTime.now().subtract(const Duration(days: 8)),
        items: ['تروبيكال سموذي'], total: 3.50,
        status: OrderStatus.cancelled, branch: 'فرع المدينة الرياضية',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('تاريخ الطلبات', style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
        )),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSizes.paddingSM),
        itemBuilder: (context, index) {
          final order = orders[index];
          return _OrderCard(order: order, isDark: isDark, theme: theme);
        },
      ),
    );
  }
}

class _MockOrder {
  final String id;
  final DateTime date;
  final List<String> items;
  final double total;
  final OrderStatus status;
  final String branch;

  const _MockOrder({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
    required this.status,
    required this.branch,
  });
}

class _OrderCard extends StatelessWidget {
  final _MockOrder order;
  final bool isDark;
  final ThemeData theme;

  const _OrderCard({
    required this.order,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isCancelled = order.status == OrderStatus.cancelled;

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: isCancelled ? Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
        ) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الصف العلوي: رقم الطلب + الحالة
          Row(
            children: [
              Text(order.id, style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              )),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isCancelled
                      ? AppColors.error.withValues(alpha: 0.12)
                      : AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Text(
                  order.status.label,
                  style: TextStyle(
                    color: isCancelled ? AppColors.error : AppColors.success,
                    fontSize: 12, fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingSM),

          // العناصر
          Text(
            order.items.join(' • '),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSizes.paddingSM),

          // التفاصيل
          Row(
            children: [
              Icon(Icons.store_rounded, size: 14,
                  color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint),
              const SizedBox(width: 4),
              Text(order.branch, style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
              )),
              const Spacer(),
              Text(_formatDate(order.date), style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
              )),
            ],
          ),
          const SizedBox(height: AppSizes.paddingSM),

          // المجموع + زر إعادة الطلب
          Row(
            children: [
              Text('${order.total.toStringAsFixed(2)} JOD',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryYellow, fontWeight: FontWeight.w800,
                  )),
              const Spacer(),
              if (!isCancelled)
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('سيتم ربطها بالـ API قريباً')),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryYellow.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh_rounded, size: 16, color: AppColors.primaryYellow),
                        const SizedBox(width: 4),
                        Text('إعادة الطلب', style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.primaryYellow, fontWeight: FontWeight.w700,
                        )),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inHours < 24) return 'اليوم';
    if (diff.inDays == 1) return 'أمس';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';
    return '${date.day}/${date.month}';
  }
}
