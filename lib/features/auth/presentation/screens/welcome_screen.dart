import 'package:flutter/material.dart';
import 'package:shalmoneh_app/core/theme/app_colors.dart';
import 'package:shalmoneh_app/core/constants/app_sizes.dart';
import 'package:shalmoneh_app/shared_widgets/yellow_button.dart';

/// شاشة الترحيب — 3 صفحات Onboarding + زر "ابدأ الآن"
class WelcomeScreen extends StatefulWidget {
  final VoidCallback onGetStarted;

  const WelcomeScreen({super.key, required this.onGetStarted});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  final _pages = const [
    _OnboardingPage(
      icon: Icons.local_drink_rounded,
      iconColor: AppColors.primaryYellow,
      title: 'أهلاً بك في شلمونة! 🥤',
      subtitle: 'اكتشف أشهى العصائر الطبيعية والمشروبات المميزة',
    ),
    _OnboardingPage(
      icon: Icons.star_rounded,
      iconColor: AppColors.primaryYellow,
      title: 'اجمع شلموناتك ⭐',
      subtitle: 'كل طلب يقربك من مشروبك المجاني!\nاجمع النقاط واستمتع بالمكافآت',
    ),
    _OnboardingPage(
      icon: Icons.flash_on_rounded,
      iconColor: AppColors.primaryYellow,
      title: 'اطلب بنقرة واحدة ⚡',
      subtitle: 'خصّص مشروبك، احفظه، وأعد طلبه بلحظة',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ─── زر تخطي ───
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingMD),
                child: TextButton(
                  onPressed: widget.onGetStarted,
                  child: Text(
                    'تخطي',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
              ),
            ),

            // ─── صفحات Onboarding ───
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, index) => _pages[index],
              ),
            ),

            // ─── مؤشر النقاط ───
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMD),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _currentPage == i ? 28 : 10,
                    height: 10,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: _currentPage == i
                          ? AppColors.primaryYellow
                          : (isDark
                              ? AppColors.darkCard
                              : AppColors.lightDivider),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
            ),

            // ─── الزر ───
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.paddingLG,
                0,
                AppSizes.paddingLG,
                AppSizes.paddingXL,
              ),
              child: YellowButton(
                text: _currentPage == _pages.length - 1
                    ? 'ابدأ الآن 🚀'
                    : 'التالي',
                icon: _currentPage == _pages.length - 1
                    ? null
                    : Icons.arrow_back_rounded,
                onPressed: () {
                  if (_currentPage == _pages.length - 1) {
                    widget.onGetStarted();
                  } else {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// صفحة Onboarding واحدة
class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _OnboardingPage({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // أيقونة كبيرة
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 70, color: iconColor),
          ),
          const SizedBox(height: AppSizes.paddingXL),

          // العنوان
          Text(
            title,
            style: theme.textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.paddingMD),

          // الوصف
          Text(
            subtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              height: 1.8,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
