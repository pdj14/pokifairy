import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokifairy/features/home/home_page.dart';
import 'package:pokifairy/features/landing/landing_page.dart';
import 'package:pokifairy/features/onboarding/onboarding_page.dart';

/// 앱 경로 정의.
enum AppRoute { root, landing, onboarding, home }

extension AppRoutePath on AppRoute {
  String get path => switch (this) {
        AppRoute.root => '/',
        AppRoute.landing => '/',
        AppRoute.onboarding => '/onboarding',
        AppRoute.home => '/home',
      };

  String get name => switch (this) {
        AppRoute.root => 'root',
        AppRoute.landing => 'landing',
        AppRoute.onboarding => 'onboarding',
        AppRoute.home => 'home',
      };
}

/// GoRouter 프로바이더.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoute.landing.path,
    routes: [
      GoRoute(
        path: AppRoute.landing.path,
        name: AppRoute.landing.name,
        builder: (context, state) => const LandingPage(),
      ),
      GoRoute(
        path: AppRoute.onboarding.path,
        name: AppRoute.onboarding.name,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoute.home.path,
        name: AppRoute.home.name,
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
});
