import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shalmoneh_app/core/theme/app_colors.dart';
import 'package:shalmoneh_app/core/constants/app_sizes.dart';
import 'package:shalmoneh_app/features/menu/data/models/product_model.dart';
import 'package:shalmoneh_app/features/menu/presentation/screens/product_detail_screen.dart';
import 'package:shalmoneh_app/features/menu/providers/menu_provider.dart';

/// شاشة المنيو — تصنيفات + شبكة منتجات + بحث — مربوطة بـ API
class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  String? _selectedCategoryId;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final categoriesAsync = ref.watch(categoriesProvider);

    // فلتر المنتجات
    final filter = ProductFilter(
      categoryId: _searchQuery.isEmpty ? _selectedCategoryId : null,
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
    );
    final productsAsync = ref.watch(productsProvider(filter));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ─── عنوان + بحث ───
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.paddingMD, AppSizes.paddingMD, AppSizes.paddingMD, 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('المنيو 🥤', style: theme.textTheme.displaySmall),
                  const SizedBox(height: AppSizes.paddingSM),
                  // شريط البحث
                  TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'ابحث عن مشروبك...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.paddingSM),

            // ─── تصنيفات من API ───
            if (_searchQuery.isEmpty)
              categoriesAsync.when(
                data: (categories) => SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
                    separatorBuilder: (_, __) => const SizedBox(width: AppSizes.paddingSM),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isSelected =
                          _selectedCategoryId == cat.id ||
                          (_selectedCategoryId == null && index == 0);
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategoryId = cat.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryYellow
                                : (isDark ? AppColors.darkCard : AppColors.lightCard),
                            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                            border: isSelected ? null : Border.all(
                              color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${cat.icon} ${cat.name}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: isSelected ? AppColors.onPrimary : null,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                loading: () => const SizedBox(
                  height: 44,
                  child: Center(child: CircularProgressIndicator(color: AppColors.primaryYellow)),
                ),
                error: (e, _) => const SizedBox.shrink(),
              ),
            const SizedBox(height: AppSizes.paddingSM),

            // ─── شبكة المنتجات من API ───
            Expanded(
              child: productsAsync.when(
                data: (products) {
                  if (products.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 60,
                              color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint),
                          const SizedBox(height: AppSizes.paddingMD),
                          Text('لا توجد نتائج', style: theme.textTheme.titleMedium),
                        ],
                      ),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppSizes.menuGridSpacing,
                      mainAxisSpacing: AppSizes.menuGridSpacing,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _MenuProductCard(
                        product: product,
                        isDark: isDark,
                        theme: theme,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => Directionality(
                                textDirection: TextDirection.rtl,
                                child: ProductDetailScreen(product: product),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryYellow),
                ),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_off_rounded, size: 60, color: Colors.grey),
                      const SizedBox(height: AppSizes.paddingMD),
                      Text('خطأ في تحميل المنتجات', style: theme.textTheme.titleMedium),
                      TextButton(
                        onPressed: () => ref.invalidate(productsProvider(filter)),
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// بطاقة منتج في المنيو
class _MenuProductCard extends StatelessWidget {
  final ProductModel product;
  final bool isDark;
  final ThemeData theme;
  final VoidCallback onTap;

  const _MenuProductCard({
    required this.product,
    required this.isDark,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الصورة
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow.withValues(alpha: 0.08),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppSizes.radiusLG),
                  ),
                ),
                child: product.imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppSizes.radiusLG),
                        ),
                        child: Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Icon(
                              Icons.local_drink_rounded,
                              size: 50,
                              color: AppColors.primaryYellow.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.local_drink_rounded,
                          size: 50,
                          color: AppColors.primaryYellow.withValues(alpha: 0.6),
                        ),
                      ),
              ),
            ),
            // المعلومات
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingSM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${product.priceM.toStringAsFixed(2)} JOD',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.primaryYellow,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (product.isPopular)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryYellow.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('🔥',
                                style: TextStyle(fontSize: 12)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
