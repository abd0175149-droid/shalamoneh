import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shalmoneh_app/core/theme/app_colors.dart';
import 'package:shalmoneh_app/core/constants/app_sizes.dart';
import 'package:shalmoneh_app/core/data/mock_data.dart';
import 'package:shalmoneh_app/features/menu/providers/favorites_provider.dart';
import 'package:shalmoneh_app/features/menu/presentation/screens/product_detail_screen.dart';

/// شاشة المشروبات المفضلة
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final favoriteIds = ref.watch(favoritesProvider);
    final favoriteProducts = MockData.products
        .where((p) => favoriteIds.contains(p.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('المشروبات المفضلة ❤️'),
        centerTitle: true,
      ),
      body: favoriteProducts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border_rounded,
                      size: 80,
                      color: AppColors.primaryYellow.withValues(alpha: 0.3)),
                  const SizedBox(height: AppSizes.paddingMD),
                  Text('لا توجد مفضلات بعد',
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSizes.paddingSM),
                  Text(
                    'اضغط ❤️ على أي مشروب لإضافته هنا',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSizes.paddingMD),
              itemCount: favoriteProducts.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSizes.paddingSM),
              itemBuilder: (context, index) {
                final product = favoriteProducts[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Directionality(
                          textDirection: TextDirection.rtl,
                          child: ProductDetailScreen(product: product),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppSizes.paddingMD),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusLG),
                      boxShadow: isDark
                          ? []
                          : [
                              BoxShadow(
                                color:
                                    Colors.black.withValues(alpha: 0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Row(
                      children: [
                        // أيقونة المنتج
                        Container(
                          width: 55,
                          height: 55,
                          decoration: BoxDecoration(
                            color: AppColors.primaryYellow
                                .withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusMD),
                          ),
                          child: Icon(Icons.local_drink_rounded,
                              color: AppColors.primaryYellow
                                  .withValues(alpha: 0.6),
                              size: 28),
                        ),
                        const SizedBox(width: AppSizes.paddingMD),
                        // الاسم والوصف
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product.name,
                                  style: theme.textTheme.titleSmall
                                      ?.copyWith(
                                          fontWeight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text(
                                '${product.priceM.toStringAsFixed(2)} JOD',
                                style: theme.textTheme.labelMedium
                                    ?.copyWith(
                                  color: AppColors.primaryYellow,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // زر حذف
                        IconButton(
                          onPressed: () {
                            ref
                                .read(favoritesProvider.notifier)
                                .toggleFavorite(product.id);
                          },
                          icon: const Icon(Icons.favorite_rounded,
                              color: Colors.red, size: 24),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
