import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shalmoneh_app/core/theme/app_colors.dart';
import 'package:shalmoneh_app/core/constants/app_sizes.dart';
import 'package:shalmoneh_app/features/menu/data/models/product_model.dart';
import 'package:shalmoneh_app/features/menu/data/models/customization_model.dart';
import 'package:shalmoneh_app/features/menu/data/models/cart_item_model.dart';
import 'package:shalmoneh_app/features/menu/providers/cart_provider.dart';
import 'package:shalmoneh_app/features/menu/providers/favorites_provider.dart';

/// شاشة تفاصيل المنتج — ⚠️ الأكثر تعقيداً
/// صورة + تخصيص (حجم/سكر/ثلج/إضافات) + سعر ديناميكي لحظي
class ProductDetailScreen extends ConsumerStatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  DrinkSize _selectedSize = DrinkSize.M;
  SugarLevel _sugarLevel = SugarLevel.medium;
  IceLevel _iceLevel = IceLevel.medium;
  final List<AddonModel> _selectedAddons = [];
  int _quantity = 1;

  /// السعر الديناميكي اللحظي
  double get _currentPrice {
    final sizePrice = widget.product.priceForSize(_selectedSize.shortLabel);
    final addonsPrice =
        _selectedAddons.fold(0.0, (sum, a) => sum + a.price);
    return (sizePrice + addonsPrice) * _quantity;
  }

  void _addToCart() {
    final item = CartItemModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      product: widget.product,
      selectedSize: _selectedSize,
      sugarLevel: _sugarLevel,
      iceLevel: _iceLevel,
      selectedAddons: List.from(_selectedAddons),
      quantity: _quantity,
    );

    // ─── إضافة للسلة عبر Provider ───
    ref.read(cartProvider.notifier).addItem(item);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'تمت إضافة ${widget.product.name} للسلة ✨',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── AppBar مع الصورة ───
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
              ),
            ),
            actions: [
              Consumer(builder: (context, ref, _) {
                final isFav = ref.watch(favoritesProvider).contains(widget.product.id);
                return IconButton(
                  onPressed: () => ref.read(favoritesProvider.notifier).toggleFavorite(widget.product.id),
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isFav ? Colors.red : Colors.white,
                    ),
                  ),
                );
              }),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primaryYellow.withValues(alpha: 0.2),
                      isDark ? AppColors.darkBackground : AppColors.lightBackground,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      // أيقونة المنتج (ستُستبدل بصورة حقيقية)
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: AppColors.primaryYellow.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryYellow.withValues(alpha: 0.2),
                              blurRadius: 30,
                              spreadRadius: 5,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.local_drink_rounded,
                          size: 70,
                          color: AppColors.primaryYellow,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── محتوى التفاصيل ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingLG),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // الاسم والوصف
                  Text(widget.product.name, style: theme.textTheme.headlineMedium),
                  const SizedBox(height: AppSizes.paddingSM),
                  Text(
                    widget.product.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingLG),

                  // ─── اختيار الحجم ───
                  _SectionTitle(title: '📏 الحجم', theme: theme),
                  const SizedBox(height: AppSizes.paddingSM),
                  Row(
                    children: DrinkSize.values.map((size) {
                      final isSelected = _selectedSize == size;
                      final price = widget.product.priceForSize(size.shortLabel);
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedSize = size),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMD),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryYellow
                                  : (isDark ? AppColors.darkCard : AppColors.lightCard),
                              borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                              border: isSelected ? null : Border.all(
                                color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  size.shortLabel,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: isSelected ? AppColors.onPrimary : null,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  size.label,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isSelected ? AppColors.onPrimary : null,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${price.toStringAsFixed(2)} JOD',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: isSelected ? AppColors.onPrimary : AppColors.primaryYellow,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSizes.paddingLG),

                  // ─── شريط السكر ───
                  _SectionTitle(title: '🍬 نسبة السكر', theme: theme),
                  const SizedBox(height: AppSizes.paddingSM),
                  _LevelSelector(
                    levels: SugarLevel.values,
                    selectedIndex: _sugarLevel.index,
                    labels: SugarLevel.values.map((s) => s.label).toList(),
                    isDark: isDark,
                    theme: theme,
                    onChanged: (i) => setState(() => _sugarLevel = SugarLevel.values[i]),
                  ),
                  const SizedBox(height: AppSizes.paddingLG),

                  // ─── شريط الثلج ───
                  _SectionTitle(title: '🧊 نسبة الثلج', theme: theme),
                  const SizedBox(height: AppSizes.paddingSM),
                  _LevelSelector(
                    levels: IceLevel.values,
                    selectedIndex: _iceLevel.index,
                    labels: IceLevel.values.map((s) => s.label).toList(),
                    isDark: isDark,
                    theme: theme,
                    onChanged: (i) => setState(() => _iceLevel = IceLevel.values[i]),
                  ),
                  const SizedBox(height: AppSizes.paddingLG),

                  // ─── الإضافات ───
                  if (widget.product.availableAddons.isNotEmpty) ...[
                    _SectionTitle(title: '✨ الإضافات', theme: theme),
                    const SizedBox(height: AppSizes.paddingSM),
                    ...widget.product.availableAddons.map((addon) {
                      final isSelected = _selectedAddons.contains(addon);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedAddons.remove(addon);
                            } else {
                              _selectedAddons.add(addon);
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: AppSizes.paddingSM),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingMD,
                            vertical: AppSizes.paddingSM + 4,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryYellow.withValues(alpha: 0.12)
                                : (isDark ? AppColors.darkCard : AppColors.lightCard),
                            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryYellow
                                  : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? Icons.check_circle : Icons.add_circle_outline,
                                color: isSelected ? AppColors.primaryYellow : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                              ),
                              const SizedBox(width: AppSizes.paddingSM),
                              Expanded(
                                child: Text(
                                  addon.name,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                '+${addon.price.toStringAsFixed(2)} JOD',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: AppColors.primaryYellow,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: AppSizes.paddingSM),
                  ],

                  // مسافة للشريط السفلي
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // ─── الشريط السفلي الثابت (سعر + كمية + زر) ───
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.paddingLG, AppSizes.paddingMD, AppSizes.paddingLG, AppSizes.paddingLG,
        ),
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
          child: Row(
            children: [
              // عداد الكمية
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _quantity > 1
                          ? () => setState(() => _quantity--)
                          : null,
                      icon: const Icon(Icons.remove_rounded),
                      iconSize: 20,
                    ),
                    Text(
                      '$_quantity',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _quantity++),
                      icon: const Icon(Icons.add_rounded),
                      iconSize: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.paddingMD),

              // زر أضف للسلة + السعر
              Expanded(
                child: GestureDetector(
                  onTap: _addToCart,
                  child: Container(
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_cart_rounded,
                            color: AppColors.onPrimary, size: 22),
                        const SizedBox(width: 8),
                        const Text(
                          'أضف للسلة',
                          style: TextStyle(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${_currentPrice.toStringAsFixed(2)} JOD',
                            style: const TextStyle(
                              color: AppColors.onPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
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

// ══════════════════════════════════════════
//  مكونات مساعدة
// ══════════════════════════════════════════

class _SectionTitle extends StatelessWidget {
  final String title;
  final ThemeData theme;

  const _SectionTitle({required this.title, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700));
  }
}

class _LevelSelector<T extends Enum> extends StatelessWidget {
  final List<T> levels;
  final int selectedIndex;
  final List<String> labels;
  final bool isDark;
  final ThemeData theme;
  final ValueChanged<int> onChanged;

  const _LevelSelector({
    required this.levels,
    required this.selectedIndex,
    required this.labels,
    required this.isDark,
    required this.theme,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(levels.length, (index) {
        final isSelected = selectedIndex == index;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingSM + 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryYellow
                    : (isDark ? AppColors.darkCard : AppColors.lightCard),
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                border: isSelected ? null : Border.all(
                  color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                ),
              ),
              child: Center(
                child: Text(
                  labels[index],
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isSelected ? AppColors.onPrimary : null,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
