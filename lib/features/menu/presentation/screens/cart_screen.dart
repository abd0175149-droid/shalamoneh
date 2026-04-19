import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shalmoneh_app/core/theme/app_colors.dart';
import 'package:shalmoneh_app/core/constants/app_sizes.dart';
import 'package:shalmoneh_app/features/menu/providers/cart_provider.dart';
import 'package:shalmoneh_app/features/menu/data/models/cart_item_model.dart';
import 'package:shalmoneh_app/features/menu/presentation/screens/checkout_screen.dart';

/// شاشة السلة — قائمة العناصر + ملخص الأسعار + تأكيد الطلب
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cartTotal = ref.watch(cartTotalProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('السلة (${cartItems.length})',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        centerTitle: true,
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => Directionality(
                    textDirection: TextDirection.rtl,
                    child: AlertDialog(
                      title: const Text('تفريغ السلة'),
                      content: const Text('هل أنت متأكد من حذف جميع العناصر؟'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('إلغاء'),
                        ),
                        TextButton(
                          onPressed: () {
                            ref.read(cartProvider.notifier).clearCart();
                            Navigator.pop(context);
                          },
                          child: const Text('حذف الكل',
                              style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.delete_outline_rounded),
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? _EmptyCart(theme: theme, isDark: isDark, onBrowse: () => Navigator.pop(context))
          : ListView.separated(
              padding: const EdgeInsets.all(AppSizes.paddingMD),
              itemCount: cartItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSizes.paddingSM),
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return _CartItemCard(
                  item: item,
                  isDark: isDark,
                  theme: theme,
                  onIncrease: () {
                    ref.read(cartProvider.notifier).updateQuantity(item.id, item.quantity + 1);
                  },
                  onDecrease: () {
                    ref.read(cartProvider.notifier).updateQuantity(item.id, item.quantity - 1);
                  },
                  onRemove: () {
                    ref.read(cartProvider.notifier).removeItem(item.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تم حذف ${item.product.name}'),
                        action: SnackBarAction(
                          label: 'تراجع',
                          onPressed: () {
                            ref.read(cartProvider.notifier).addItem(item);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),

      // ─── شريط سفلي (المجموع + زر التأكيد) ───
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(AppSizes.paddingLG),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ملخص الأسعار
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('المجموع الفرعي', style: theme.textTheme.bodyMedium),
                        Text('${cartTotal.toStringAsFixed(2)} JOD',
                            style: theme.textTheme.bodyMedium),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('الضريبة', style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        )),
                        Text('0.00 JOD', style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        )),
                      ],
                    ),
                    const Divider(height: AppSizes.paddingMD),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('المجموع الكلي', style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        )),
                        Text('${cartTotal.toStringAsFixed(2)} JOD', style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.primaryYellow,
                          fontWeight: FontWeight.w800,
                        )),
                      ],
                    ),
                    const SizedBox(height: AppSizes.paddingMD),

                    // زر التأكيد
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const Directionality(
                            textDirection: TextDirection.rtl,
                            child: CheckoutScreen(),
                          ),
                        ));
                      },
                      child: Container(
                        width: double.infinity,
                        height: AppSizes.buttonHeight,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryYellow.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('تأكيد الطلب 🛒',
                            style: TextStyle(
                              color: AppColors.onPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// ─── بطاقة عنصر في السلة ───
class _CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final bool isDark;
  final ThemeData theme;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.item,
    required this.isDark,
    required this.theme,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: AppSizes.paddingLG),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => onRemove(),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        ),
        child: Row(
          children: [
            // أيقونة المنتج
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primaryYellow.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              ),
              child: const Icon(Icons.local_drink_rounded,
                  color: AppColors.primaryYellow, size: 28),
            ),
            const SizedBox(width: AppSizes.paddingSM),

            // المعلومات
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.product.name, style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  )),
                  const SizedBox(height: 2),
                  Text(
                    item.customizationSummary,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.totalPrice.toStringAsFixed(2)} JOD',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.primaryYellow,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            // عداد الكمية
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: onDecrease,
                    icon: Icon(
                      item.quantity > 1 ? Icons.remove_rounded : Icons.delete_rounded,
                      size: 18,
                      color: item.quantity > 1 ? null : AppColors.error,
                    ),
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                  Text('${item.quantity}', style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  )),
                  IconButton(
                    onPressed: onIncrease,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── حالة السلة الفارغة ───
class _EmptyCart extends StatelessWidget {
  final ThemeData theme;
  final bool isDark;
  final VoidCallback onBrowse;

  const _EmptyCart({required this.theme, required this.isDark, required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80,
              color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint),
          const SizedBox(height: AppSizes.paddingMD),
          Text('سلتك فارغة', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSizes.paddingSM),
          Text('اكتشف المنيو وأضف مشروبك المفضل!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              )),
          const SizedBox(height: AppSizes.paddingLG),
          GestureDetector(
            onTap: onBrowse,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingXL, vertical: AppSizes.paddingSM + 4,
              ),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
              child: const Text('تصفح المنيو 🥤',
                  style: TextStyle(color: AppColors.onPrimary, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
