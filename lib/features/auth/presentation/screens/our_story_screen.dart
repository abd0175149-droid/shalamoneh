import 'package:flutter/material.dart';
import 'package:shalmoneh_app/core/theme/app_colors.dart';
import 'package:shalmoneh_app/core/constants/app_sizes.dart';

/// صفحة "قصة شلمونة" — قصة التأسيس بتصميم سردي أنيق مع Parallax
class OurStoryScreen extends StatelessWidget {
  const OurStoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── AppBar ───
          SliverAppBar(
            expandedHeight: 250,
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
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primaryYellow.withValues(alpha: 0.3),
                      isDark ? AppColors.darkBackground : AppColors.lightBackground,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryYellow.withValues(alpha: 0.4),
                              blurRadius: 20,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.local_drink_rounded,
                          size: 50,
                          color: AppColors.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'قصة شلمونة',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryYellow,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── المحتوى ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingLG),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── الفصل الأول ───
                  _StoryChapter(
                    number: '01',
                    title: 'البداية 🌱',
                    content:
                        'بدأت شلمونة عام 2010 كفكرة بسيطة: تقديم أفضل العصائر الطبيعية '
                        'بجودة لا تُضاهى. من كشك صغير في عمّان، ولدت قصة نجاح غيّرت مفهوم '
                        'المشروبات الطازجة في المنطقة.',
                    isDark: isDark,
                    theme: theme,
                  ),
                  const SizedBox(height: AppSizes.paddingXL),

                  // ─── الإحصائيات ───
                  Row(
                    children: [
                      _StatCard(
                        icon: Icons.store_rounded,
                        value: '50+',
                        label: 'فرع',
                        isDark: isDark,
                        theme: theme,
                      ),
                      const SizedBox(width: AppSizes.paddingSM),
                      _StatCard(
                        icon: Icons.people_rounded,
                        value: '270+',
                        label: 'موظف',
                        isDark: isDark,
                        theme: theme,
                      ),
                      const SizedBox(width: AppSizes.paddingSM),
                      _StatCard(
                        icon: Icons.flag_rounded,
                        value: '4',
                        label: 'دول',
                        isDark: isDark,
                        theme: theme,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingXL),

                  // ─── الفصل الثاني ───
                  _StoryChapter(
                    number: '02',
                    title: 'النمو 🚀',
                    content:
                        'خلال سنوات قليلة، توسعت شلمونة من فرع واحد إلى أكثر من 50 فرعاً '
                        'في 4 دول: الأردن، السعودية، العراق، وفلسطين. مع فريق يضم أكثر من '
                        '270 موظفاً يعملون بشغف لتقديم أفضل تجربة.',
                    isDark: isDark,
                    theme: theme,
                  ),
                  const SizedBox(height: AppSizes.paddingXL),

                  // ─── الفصل الثالث ───
                  _StoryChapter(
                    number: '03',
                    title: 'الرؤية 🔮',
                    content:
                        'رؤيتنا: أن نكون الخيار الأول لكل من يبحث عن مشروب طبيعي ولذيذ '
                        'في كل حي، في كل مدينة. نؤمن بأن الطبيعة تقدم أفضل النكهات، '
                        'ومهمتنا إيصالها إليك بأعلى جودة وبابتسامة.',
                    isDark: isDark,
                    theme: theme,
                  ),
                  const SizedBox(height: AppSizes.paddingXL),

                  // ─── القيم ───
                  Text(
                    'قيمنا 💛',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingMD),
                  _ValueCard(
                    emoji: '🍊',
                    title: 'الطبيعة أولاً',
                    desc: 'مكونات طبيعية 100% بدون مواد حافظة',
                    isDark: isDark, theme: theme,
                  ),
                  _ValueCard(
                    emoji: '⭐',
                    title: 'الجودة بلا تنازل',
                    desc: 'معايير صارمة في كل كوب نقدمه',
                    isDark: isDark, theme: theme,
                  ),
                  _ValueCard(
                    emoji: '😊',
                    title: 'ابتسامة في كل زيارة',
                    desc: 'خدمة ودودة تجعل يومك أجمل',
                    isDark: isDark, theme: theme,
                  ),
                  _ValueCard(
                    emoji: '🌍',
                    title: 'مسؤولية مجتمعية',
                    desc: 'دعم المزارعين المحليين والبيئة',
                    isDark: isDark, theme: theme,
                  ),

                  const SizedBox(height: AppSizes.paddingXL),

                  // ─── الشعار ───
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'شلمونة',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryYellow,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '— طعم الحياة —',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingXXL),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════
//  مكونات القصة
// ══════════════════════════════════════════

class _StoryChapter extends StatelessWidget {
  final String number;
  final String title;
  final String content;
  final bool isDark;
  final ThemeData theme;

  const _StoryChapter({
    required this.number,
    required this.title,
    required this.content,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // رقم الفصل
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primaryYellow.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: AppColors.primaryYellow,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSizes.paddingMD),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: AppSizes.paddingSM),
              Text(
                content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  height: 1.8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool isDark;
  final ThemeData theme;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMD),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          border: Border.all(
            color: AppColors.primaryYellow.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryYellow, size: 28),
            const SizedBox(height: 6),
            Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _ValueCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String desc;
  final bool isDark;
  final ThemeData theme;

  const _ValueCard({
    required this.emoji,
    required this.title,
    required this.desc,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingSM),
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: AppSizes.paddingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(desc, style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
