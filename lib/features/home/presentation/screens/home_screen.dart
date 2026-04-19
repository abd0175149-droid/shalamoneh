import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shalmoneh_app/core/theme/app_colors.dart';
import 'package:shalmoneh_app/core/constants/app_sizes.dart';
import 'package:shalmoneh_app/features/menu/data/models/product_model.dart';
import 'package:shalmoneh_app/features/menu/presentation/screens/product_detail_screen.dart';
import 'package:shalmoneh_app/features/menu/providers/favorites_provider.dart';
import 'package:shalmoneh_app/features/menu/providers/menu_provider.dart';
import 'package:shalmoneh_app/features/auth/providers/auth_provider.dart';

/// الشاشة الرئيسية — بانر + نقاط + تصنيفات + منتجات من API
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final favoriteIds = ref.watch(favoritesProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final authState = ref.watch(authProvider);

    // جلب المنتجات حسب الفلتر
    final filter = ProductFilter(
      categoryId: _selectedCategoryId,
      popular: _selectedCategoryId == null,
    );
    final productsAsync = ref.watch(productsProvider(filter));

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ─── شريط علوي ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingMD),
                child: Row(
                  children: [
                    _buildIconButton(
                      Icons.notifications_none_rounded,
                      isDark,
                      () {},
                    ),
                    const Spacer(),
                    Text(
                      'شلمونة',
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: AppColors.primaryYellow,
                      ),
                    ),
                    const Spacer(),
                    _buildIconButton(
                      Icons.person_outline_rounded,
                      isDark,
                      () {},
                    ),
                  ],
                ),
              ),
            ),

            // ─── ترحيب بالمستخدم ───
            if (authState.user?.name != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
                  child: Text(
                    'أهلاً ${authState.user!.name} 👋',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            // ─── بانر ترويجي ───
            SliverToBoxAdapter(
              child: _BannerCarousel(isDark: isDark),
            ),

            // ─── شريط النقاط المصغر ───
            SliverToBoxAdapter(
              child: _LoyaltyMiniBar(isDark: isDark, theme: theme),
            ),

            // ─── التصنيفات من API ───
            SliverToBoxAdapter(
              child: categoriesAsync.when(
                data: (categories) => _buildCategorySection(theme, isDark, categories),
                loading: () => const Padding(
                  padding: EdgeInsets.all(AppSizes.paddingMD),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primaryYellow)),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingMD),
                  child: Text('خطأ في تحميل التصنيفات: $e'),
                ),
              ),
            ),

            // ─── عنوان المنتجات ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMD,
                ),
                child: Row(
                  children: [
                    Text(
                      _selectedCategoryId == null ? '🔥 الأكثر طلباً' : '📂 المنتجات',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: const Text('عرض الكل'),
                    ),
                  ],
                ),
              ),
            ),

            // ─── شبكة المنتجات من API ───
            productsAsync.when(
              data: (products) {
                final displayProducts = products.take(4).toList();
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingMD,
                  ),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: AppSizes.menuGridColumns,
                      crossAxisSpacing: AppSizes.menuGridSpacing,
                      mainAxisSpacing: AppSizes.menuGridSpacing,
                      childAspectRatio: _getCardAspectRatio(context),
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = displayProducts[index];
                        final isFav = favoriteIds.contains(product.id);
                        return _buildProductCard(
                            product, isFav, theme, isDark, context);
                      },
                      childCount: displayProducts.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: AppColors.primaryYellow),
                  ),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text('خطأ في تحميل المنتجات', style: theme.textTheme.bodyMedium),
                        TextButton(
                          onPressed: () => ref.invalidate(productsProvider(filter)),
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // مسافة للـ Bottom Nav
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  /// حساب aspect ratio ديناميكي حسب حجم الشاشة
  double _getCardAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) return 1.1; // تابلت
    if (width > 400) return 0.92; // موبايل عادي
    return 0.85; // موبايل صغير
  }

  // ════════════════════════════════════════════
  //  قسم التصنيفات (من API)
  // ════════════════════════════════════════════
  Widget _buildCategorySection(ThemeData theme, bool isDark, List<CategoryModel> apiCategories) {
    // إضافة "الكل" في البداية
    final categories = [
      {'id': null, 'icon': Icons.whatshot_rounded, 'name': 'الكل', 'color': AppColors.primaryYellow},
      ...apiCategories.map((c) => {
        'id': c.id,
        'icon': _getCategoryIcon(c.icon),
        'name': c.name,
        'color': _getCategoryColor(c.name),
      }),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingSM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingMD,
            ),
            child:
                Text('📂 التصنيفات', style: theme.textTheme.headlineSmall),
          ),
          const SizedBox(height: AppSizes.paddingSM),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMD,
              ),
              itemCount: categories.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppSizes.paddingSM),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final catId = cat['id'] as String?;
                final isSelected = _selectedCategoryId == catId;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedCategoryId = catId);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 85,
                    padding: const EdgeInsets.all(AppSizes.paddingSM),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryYellow.withValues(alpha: 0.2)
                          : (isDark
                              ? AppColors.darkCard
                              : AppColors.lightCard),
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusLG),
                      border: isSelected
                          ? Border.all(
                              color: AppColors.primaryYellow, width: 2)
                          : null,
                      boxShadow: isDark
                          ? []
                          : [
                              BoxShadow(
                                color:
                                    Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                              ),
                            ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: (cat['color'] as Color)
                                .withValues(alpha: isSelected ? 0.3 : 0.15),
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMD,
                            ),
                          ),
                          child: Icon(
                            cat['icon'] as IconData,
                            color: cat['color'] as Color,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          cat['name'] as String,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isSelected
                                ? AppColors.primaryYellow
                                : null,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSizes.paddingMD),
        ],
      ),
    );
  }

  /// تحويل emoji/icon string لـ IconData
  IconData _getCategoryIcon(String icon) {
    switch (icon) {
      case '🍊': return Icons.local_drink_rounded;
      case '🥤': return Icons.blender;
      case '☕': return Icons.coffee_rounded;
      case '🍰': return Icons.cake_rounded;
      default: return Icons.restaurant_rounded;
    }
  }

  /// لون حسب اسم التصنيف
  Color _getCategoryColor(String name) {
    if (name.contains('عصير')) return AppColors.juiceOrange;
    if (name.contains('مكس') || name.contains('شلمونة')) return AppColors.primaryYellow;
    if (name.contains('ساخن')) return AppColors.hotDrink;
    if (name.contains('حلى')) return AppColors.dessert;
    return AppColors.primaryYellow;
  }

  // ════════════════════════════════════════════
  //  كارد المنتج (محسّن + مفضلة)
  // ════════════════════════════════════════════
  Widget _buildProductCard(ProductModel product, bool isFav,
      ThemeData theme, bool isDark, BuildContext context) {
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
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── صورة المنتج ──
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primaryYellow
                          .withValues(alpha: 0.08),
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
                                child: Icon(Icons.local_drink_rounded,
                                    size: 36,
                                    color: AppColors.primaryYellow
                                        .withValues(alpha: 0.6)),
                              ),
                            ),
                          )
                        : Center(
                            child: Icon(Icons.local_drink_rounded,
                                size: 36,
                                color: AppColors.primaryYellow
                                    .withValues(alpha: 0.6)),
                          ),
                  ),
                  // زر المفضلة ❤️
                  Positioned(
                    top: 6,
                    left: 6,
                    child: GestureDetector(
                      onTap: () {
                        ref
                            .read(favoritesProvider.notifier)
                            .toggleFavorite(product.id);
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.black54
                              : Colors.white70,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFav
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 16,
                          color: isFav ? Colors.red : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ── الاسم + السعر في صف واحد ──
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    product.priceM.toStringAsFixed(2),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.primaryYellow,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(
      IconData icon, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                  ),
                ],
        ),
        child: Icon(icon, size: 22),
      ),
    );
  }
}

/// ─── بانر ترويجي ───
class _BannerCarousel extends StatefulWidget {
  final bool isDark;
  const _BannerCarousel({required this.isDark});

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  final _controller = PageController();
  int _currentPage = 0;

  final _banners = [
    {
      'title': 'عرض الافتتاح! 🎉',
      'subtitle': 'اشترِ 2 واحصل على الثالث مجاناً',
      'gradient': [const Color(0xFFFF6B35), const Color(0xFFFF8E53)]
    },
    {
      'title': 'أنعش صيفك ☀️',
      'subtitle': 'تشكيلة جديدة من الكوكتيلات الاستوائية',
      'gradient': [const Color(0xFF1CB5E0), const Color(0xFF000851)]
    },
    {
      'title': 'شلموناتك بتزيد! ⭐',
      'subtitle': 'نقاط مضاعفة هذا الأسبوع',
      'gradient': [const Color(0xFFFFD400), const Color(0xFFFF8C00)]
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        final next = (_currentPage + 1) % _banners.length;
        _controller.animateToPage(next,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut);
        _startAutoScroll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingMD, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: banner['gradient'] as List<Color>,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingLG),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(banner['title'] as String,
                          style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(banner['subtitle'] as String,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: Colors.white70)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // مؤشرات
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
              width: _currentPage == i ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: _currentPage == i
                    ? AppColors.primaryYellow
                    : AppColors.primaryYellow.withValues(alpha: 0.25),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// ─── شريط النقاط المصغر ───
class _LoyaltyMiniBar extends StatelessWidget {
  final bool isDark;
  final ThemeData theme;
  const _LoyaltyMiniBar({required this.isDark, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMD, vertical: AppSizes.paddingSM),
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryYellow.withValues(alpha: isDark ? 0.15 : 0.1),
            AppColors.primaryYellow.withValues(alpha: isDark ? 0.08 : 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(
            color: AppColors.primaryYellow.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.star_rounded,
              color: AppColors.primaryYellow, size: 28),
          const SizedBox(width: AppSizes.paddingSM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('شلموناتك: 50',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.5,
                    backgroundColor:
                        AppColors.primaryYellow.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primaryYellow),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.paddingSM),
          Text('50 شلمونة\nللمجاني! 🎁',
              style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.primaryYellow,
                  fontWeight: FontWeight.w700),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
