import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shalmoneh_app/core/theme/app_colors.dart';
import 'package:shalmoneh_app/core/theme/theme_provider.dart';
import 'package:shalmoneh_app/core/theme/dark_theme.dart';
import 'package:shalmoneh_app/core/theme/light_theme.dart';
import 'package:shalmoneh_app/features/auth/providers/auth_provider.dart';
import 'package:shalmoneh_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:shalmoneh_app/features/auth/presentation/screens/welcome_screen.dart';
import 'package:shalmoneh_app/features/auth/presentation/screens/login_screen.dart';
import 'package:shalmoneh_app/features/auth/presentation/screens/otp_screen.dart';
import 'package:shalmoneh_app/features/auth/presentation/screens/complete_profile_screen.dart';
import 'package:shalmoneh_app/features/home/presentation/screens/home_screen.dart';
import 'package:shalmoneh_app/features/menu/presentation/screens/menu_screen.dart';
import 'package:shalmoneh_app/features/loyalty/presentation/screens/loyalty_screen.dart';
import 'package:shalmoneh_app/features/locator/presentation/screens/map_screen.dart';
import 'package:shalmoneh_app/features/auth/presentation/screens/profile_screen.dart';
import 'package:shalmoneh_app/shared_widgets/bottom_nav_bar.dart';
import 'package:shalmoneh_app/features/menu/providers/cart_provider.dart';
import 'package:shalmoneh_app/features/menu/presentation/screens/cart_screen.dart';

/// التطبيق الرئيسي — MaterialApp مع دعم Dark/Light Theme
class ShalmonehApp extends ConsumerWidget {
  const ShalmonehApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'شلمونة | Shalmoneh',
      debugShowCheckedModeBanner: false,

      // ─── الثيمات ───
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: themeMode,

      // ─── التعريب ───
      locale: const Locale('ar', 'JO'),
      supportedLocales: const [
        Locale('ar', 'JO'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ─── نقطة الدخول — Splash ───
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: AuthGate(),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  بوابة المصادقة — تدير المسار: Splash → Welcome → Login → OTP → Home
//  متصلة بـ AuthProvider + Backend API
// ══════════════════════════════════════════════════════════════
class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

enum AuthScreen { splash, welcome, login, otp, completeProfile, main }

class _AuthGateState extends ConsumerState<AuthGate> {
  AuthScreen _currentScreen = AuthScreen.splash;
  String _phoneNumber = '';
  String _verificationId = '';

  void _goTo(AuthScreen screen) {
    setState(() => _currentScreen = screen);
  }

  @override
  Widget build(BuildContext context) {
    // مراقبة حالة Auth من Provider
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated && _currentScreen != AuthScreen.main) {
        _goTo(AuthScreen.main);
      }
    });

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _buildCurrentScreen(),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentScreen) {
      case AuthScreen.splash:
        return SplashScreen(
          key: const ValueKey('splash'),
          onComplete: () {
            // تحقق من حالة Auth
            final authState = ref.read(authProvider);
            if (authState.status == AuthStatus.authenticated) {
              _goTo(AuthScreen.main);
            } else {
              _goTo(AuthScreen.welcome);
            }
          },
        );

      case AuthScreen.welcome:
        return WelcomeScreen(
          key: const ValueKey('welcome'),
          onGetStarted: () => _goTo(AuthScreen.login),
        );

      case AuthScreen.login:
        return LoginScreen(
          key: const ValueKey('login'),
          onSendOTP: (fullPhone, countryCode, verificationId) {
            _phoneNumber = fullPhone;
            _verificationId = verificationId;
            _goTo(AuthScreen.otp);
          },
          onAutoVerified: () {
            // Android auto-verify — تم التحقق تلقائياً
            final authState = ref.read(authProvider);
            if (authState.status == AuthStatus.newUser) {
              _goTo(AuthScreen.completeProfile);
            } else {
              _goTo(AuthScreen.main);
            }
          },
        );

      case AuthScreen.otp:
        return OtpScreen(
          key: const ValueKey('otp'),
          phoneNumber: _phoneNumber,
          verificationId: _verificationId,
          onVerified: () {
            final authState = ref.read(authProvider);
            if (authState.status == AuthStatus.newUser) {
              _goTo(AuthScreen.completeProfile);
            } else {
              _goTo(AuthScreen.main);
            }
          },
          onBack: () => _goTo(AuthScreen.login),
        );

      case AuthScreen.completeProfile:
        return CompleteProfileScreen(
          key: const ValueKey('complete'),
          onComplete: () {
            ref.read(authProvider.notifier).confirmProfileComplete();
            _goTo(AuthScreen.main);
          },
          onSkip: () {
            ref.read(authProvider.notifier).confirmProfileComplete();
            _goTo(AuthScreen.main);
          },
        );

      case AuthScreen.main:
        return const MainShell(key: ValueKey('main'));
    }
  }
}

// ══════════════════════════════════════════════════════════════
//  الهيكل الرئيسي — الشاشات + شريط التنقل السفلي
// ══════════════════════════════════════════════════════════════
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    if (index == 2) return;
    setState(() => _currentIndex = index);
  }

  void _onQrTapped() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const Directionality(
          textDirection: TextDirection.rtl,
          child: LoyaltyScreen(),
        ),
      ),
    );
  }

  void _openCart() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const Directionality(
          textDirection: TextDirection.rtl,
          child: CartScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(cartCountProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    int stackIndex;
    if (_currentIndex < 2) {
      stackIndex = _currentIndex;
    } else if (_currentIndex > 2) {
      stackIndex = _currentIndex - 1;
    } else {
      stackIndex = 0;
    }

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: stackIndex,
            children: const [
              HomeScreen(),
              MenuScreen(),
              MapScreen(),
              ProfileScreen(),
            ],
          ),
          // ─── زر السلة العائم ───
          if (cartCount > 0)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              child: GestureDetector(
                onTap: _openCart,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryYellow.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_cart_rounded,
                          color: AppColors.onPrimary, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        '$cartCount',
                        style: TextStyle(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: ShalmonehBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        onQrTap: _onQrTapped,
      ),
    );
  }
}
