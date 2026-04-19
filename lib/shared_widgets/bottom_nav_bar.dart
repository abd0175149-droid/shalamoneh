import 'package:flutter/material.dart';
import 'package:shalmoneh_app/core/theme/app_colors.dart';
import 'package:shalmoneh_app/core/constants/app_sizes.dart';

/// شريط التنقل السفلي — 5 عناصر مع FAB أصفر مركزي للباركود
/// من DESIGN_SYSTEM.md: الزر الأوسط = FAB عائم كبير بلون أصفر كامل
class ShalmonehBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onQrTap;

  const ShalmonehBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onQrTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Container(
      height: AppSizes.bottomNavHeight + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBottomNav : AppColors.lightBottomNav,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // ─── الرئيسية ───
            _NavItem(
              icon: Icons.home_rounded,
              label: 'الرئيسية',
              isSelected: currentIndex == 0,
              onTap: () => onTap(0),
              theme: theme,
            ),

            // ─── المنيو ───
            _NavItem(
              icon: Icons.restaurant_menu_rounded,
              label: 'المنيو',
              isSelected: currentIndex == 1,
              onTap: () => onTap(1),
              theme: theme,
            ),

            // ─── FAB الباركود (روحنا) — الزر المركزي ───
            _QrFab(onTap: onQrTap),

            // ─── الفروع ───
            _NavItem(
              icon: Icons.location_on_rounded,
              label: 'الفروع',
              isSelected: currentIndex == 3,
              onTap: () => onTap(3),
              theme: theme,
            ),

            // ─── حسابي ───
            _NavItem(
              icon: Icons.person_rounded,
              label: 'حسابي',
              isSelected: currentIndex == 4,
              onTap: () => onTap(4),
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }
}

/// عنصر واحد في شريط التنقل
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: AppSizes.animFast),
              padding: const EdgeInsets.all(AppSizes.paddingXS),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryYellow.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              ),
              child: Icon(
                icon,
                size: isSelected ? 26 : AppSizes.iconMD,
                color: isSelected
                    ? AppColors.primaryYellow
                    : (theme.brightness == Brightness.dark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10,
                color: isSelected
                    ? AppColors.primaryYellow
                    : (theme.brightness == Brightness.dark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// FAB الباركود الأصفر المركزي
class _QrFab extends StatefulWidget {
  final VoidCallback onTap;

  const _QrFab({required this.onTap});

  @override
  State<_QrFab> createState() => _QrFabState();
}

class _QrFabState extends State<_QrFab> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _pulseAnimation,
        child: Container(
          width: AppSizes.fabSize,
          height: AppSizes.fabSize,
          margin: const EdgeInsets.only(bottom: AppSizes.paddingSM),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryYellow.withValues(alpha: 0.45),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.qr_code_rounded,
            color: AppColors.onPrimary,
            size: 30,
          ),
        ),
      ),
    );
  }
}
