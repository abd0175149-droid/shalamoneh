import 'package:flutter/material.dart';
import 'package:shalmoneh_app/core/theme/app_colors.dart';
import 'package:shalmoneh_app/core/constants/app_sizes.dart';

/// بطاقة عرض المنتج — صورة مفرغة + ظل عائم + اسم + سعر
/// من DESIGN_SYSTEM.md: صور مفرغة PNG + Drop Shadow + حواف 16px
class ProductCard extends StatelessWidget {
  final String name;
  final String price;
  final String? imageUrl;
  final String? tag; // "جديد" أو "الأكثر طلباً"
  final VoidCallback? onTap;
  final String heroTag;

  const ProductCard({
    super.key,
    required this.name,
    required this.price,
    this.imageUrl,
    this.tag,
    this.onTap,
    this.heroTag = '',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: AppSizes.animFast),
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
            // ─── قسم الصورة ───
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  // الصورة المفرغة مع Drop Shadow
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.paddingMD),
                      child: Hero(
                        tag: heroTag.isEmpty ? 'product_$name' : heroTag,
                        child: _buildProductImage(isDark),
                      ),
                    ),
                  ),

                  // Badge (جديد / الأكثر طلباً)
                  if (tag != null)
                    Positioned(
                      top: AppSizes.paddingSM,
                      right: AppSizes.paddingSM,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingSM,
                          vertical: AppSizes.paddingXS,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryYellow,
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusSM),
                        ),
                        child: Text(
                          tag!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ─── قسم المعلومات ───
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMD,
                  vertical: AppSizes.paddingSM,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // اسم المنتج
                    Text(
                      name,
                      style: theme.textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSizes.paddingXS),

                    // السعر بلون أصفر
                    Text(
                      '$price JOD',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryYellow,
                        fontWeight: FontWeight.w800,
                      ),
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

  /// صورة المنتج مع تأثير Drop Shadow (3D Floating)
  Widget _buildProductImage(bool isDark) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.local_drink_rounded,
          size: AppSizes.iconXL,
          color: AppColors.primaryYellow.withValues(alpha: 0.5),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Image.network(
        imageUrl!,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Icon(
          Icons.local_drink_rounded,
          size: AppSizes.iconXL,
          color: AppColors.primaryYellow.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
