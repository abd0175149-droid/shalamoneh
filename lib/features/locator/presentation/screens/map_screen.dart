import 'package:flutter/material.dart';
import 'package:shalmoneh_app/core/theme/app_colors.dart';
import 'package:shalmoneh_app/core/constants/app_sizes.dart';
import 'package:shalmoneh_app/features/locator/data/models/branch_model.dart';

/// شاشة الفروع — قائمة فروع + فلتر مدينة + تفاصيل الفرع + اتصال
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String _selectedCity = 'الكل';
  bool _showOpenOnly = false;

  List<BranchModel> get _filteredBranches {
    var list = MockBranches.branches.toList();
    if (_selectedCity != 'الكل') {
      list = list.where((b) => b.city == _selectedCity).toList();
    }
    if (_showOpenOnly) {
      list = list.where((b) => b.isOpen).toList();
    }
    // ترتيب بالمسافة
    list.sort((a, b) => (a.distanceKm ?? 999).compareTo(b.distanceKm ?? 999));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cities = ['الكل', ...MockBranches.cities];

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── العنوان ───
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الفروع 📍', style: theme.textTheme.displaySmall),
                  const SizedBox(height: 4),
                  Text(
                    '${MockBranches.branches.length} فروع في ${MockBranches.cities.length} مدن',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // ─── فلاتر ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
              child: Row(
                children: [
                  // فلتر المدينة
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemCount: cities.length,
                        itemBuilder: (context, index) {
                          final city = cities[index];
                          final isSelected = _selectedCity == city;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedCity = city),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
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
                                child: Text(city, style: theme.textTheme.labelMedium?.copyWith(
                                  color: isSelected ? AppColors.onPrimary : null,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                )),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // فلتر المفتوح
                  GestureDetector(
                    onTap: () => setState(() => _showOpenOnly = !_showOpenOnly),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _showOpenOnly
                            ? AppColors.success.withValues(alpha: 0.15)
                            : (isDark ? AppColors.darkCard : AppColors.lightCard),
                        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                        border: Border.all(
                          color: _showOpenOnly ? AppColors.success : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time_rounded, size: 16,
                              color: _showOpenOnly ? AppColors.success : null),
                          const SizedBox(width: 4),
                          Text('مفتوح', style: theme.textTheme.labelSmall?.copyWith(
                            color: _showOpenOnly ? AppColors.success : null,
                            fontWeight: FontWeight.w600,
                          )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.paddingSM),

            // ─── قائمة الفروع ───
            Expanded(
              child: _filteredBranches.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_off_rounded, size: 60,
                              color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint),
                          const SizedBox(height: AppSizes.paddingMD),
                          Text('لا توجد فروع', style: theme.textTheme.titleMedium),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingMD, vertical: AppSizes.paddingSM,
                      ),
                      itemCount: _filteredBranches.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.paddingSM),
                      itemBuilder: (context, index) {
                        final branch = _filteredBranches[index];
                        return _BranchCard(
                          branch: branch,
                          isDark: isDark,
                          theme: theme,
                          onTap: () => _showBranchDetails(context, branch, isDark, theme),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBranchDetails(BuildContext context, BranchModel branch, bool isDark, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // المقبض
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.paddingLG),

              // الاسم + الحالة
              Row(
                children: [
                  Expanded(
                    child: Text(branch.name, style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    )),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: branch.isOpen
                          ? AppColors.success.withValues(alpha: 0.15)
                          : AppColors.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    ),
                    child: Text(
                      branch.isOpen ? 'مفتوح' : 'مغلق',
                      style: TextStyle(
                        color: branch.isOpen ? AppColors.success : AppColors.error,
                        fontSize: 12, fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingMD),

              // التفاصيل
              _DetailRow(icon: Icons.location_on_rounded, text: branch.address),
              _DetailRow(icon: Icons.location_city_rounded, text: '${branch.city}، ${branch.country}'),
              _DetailRow(icon: Icons.access_time_rounded, text: branch.workingHours),
              _DetailRow(icon: Icons.phone_rounded, text: branch.phone),
              if (branch.distanceKm != null)
                _DetailRow(icon: Icons.directions_walk_rounded,
                    text: '${branch.distanceKm!.toStringAsFixed(1)} كم'),
              const SizedBox(height: AppSizes.paddingLG),

              // أزرار
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: AppSizes.buttonHeight,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                        ),
                        child: const Center(
                          child: Text('اطلب من هذا الفرع 🛒', style: TextStyle(
                            color: AppColors.onPrimary, fontWeight: FontWeight.w700, fontSize: 15,
                          )),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingSM),
                  Container(
                    height: AppSizes.buttonHeight,
                    width: AppSizes.buttonHeight,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                      border: Border.all(
                        color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                      ),
                    ),
                    child: const Icon(Icons.phone_rounded, color: AppColors.primaryYellow),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingMD),
            ],
          ),
        ),
      ),
    );
  }
}

/// بطاقة فرع
class _BranchCard extends StatelessWidget {
  final BranchModel branch;
  final bool isDark;
  final ThemeData theme;
  final VoidCallback onTap;

  const _BranchCard({
    required this.branch,
    required this.isDark,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          boxShadow: isDark ? [] : [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
          ],
        ),
        child: Row(
          children: [
            // أيقونة الموقع
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: branch.isOpen
                    ? AppColors.primaryYellow.withValues(alpha: 0.12)
                    : AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              ),
              child: Icon(
                Icons.store_rounded,
                color: branch.isOpen ? AppColors.primaryYellow : AppColors.error,
              ),
            ),
            const SizedBox(width: AppSizes.paddingSM),
            // المعلومات
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(branch.name, style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        )),
                      ),
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          color: branch.isOpen ? AppColors.success : AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(branch.address, style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: AppSizes.paddingSM),
            // المسافة
            if (branch.distanceKm != null)
              Column(
                children: [
                  Text('${branch.distanceKm!.toStringAsFixed(1)}', style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryYellow, fontWeight: FontWeight.w800,
                  )),
                  Text('كم', style: theme.textTheme.bodySmall),
                ],
              ),
            Icon(Icons.arrow_back_ios_new_rounded, size: 14,
                color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _DetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryYellow),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
