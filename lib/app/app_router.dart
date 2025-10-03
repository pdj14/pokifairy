import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokifairy/features/ai_model/model_debug_page.dart';
import 'package:pokifairy/features/ai_model/model_selection_page.dart';
import 'package:pokifairy/features/chat/chat_page.dart';
import 'package:pokifairy/features/home/home_page.dart';
import 'package:pokifairy/features/landing/landing_page.dart';
import 'package:pokifairy/features/onboarding/onboarding_page.dart';
import 'package:pokifairy/features/settings/settings_page.dart';

/// 앱 경로 정의.
enum AppRoute { root, landing, onboarding, home, chat, modelSelection, modelDebug, settings }

extension AppRoutePath on AppRoute {
  String get path => switch (this) {
        AppRoute.root => '/',
        AppRoute.landing => '/',
        AppRoute.onboarding => '/onboarding',
        AppRoute.home => '/home',
        AppRoute.chat => '/chat',
        AppRoute.modelSelection => '/model-selection',
        AppRoute.modelDebug => '/model-debug',
        AppRoute.settings => '/settings',
      };

  String get name => switch (this) {
        AppRoute.root => 'root',
        AppRoute.landing => 'landing',
        AppRoute.onboarding => 'onboarding',
        AppRoute.home => 'home',
        AppRoute.chat => 'chat',
        AppRoute.modelSelection => 'modelSelection',
        AppRoute.modelDebug => 'modelDebug',
        AppRoute.settings => 'settings',
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
      GoRoute(
        path: AppRoute.chat.path,
        name: AppRoute.chat.name,
        builder: (context, state) => const ChatPage(),
      ),
      GoRoute(
        path: AppRoute.modelSelection.path,
        name: AppRoute.modelSelection.name,
        builder: (context, state) => const ModelSelectionPage(),
      ),
      GoRoute(
        path: AppRoute.modelDebug.path,
        name: AppRoute.modelDebug.name,
        builder: (context, state) => const ModelDebugPage(),
      ),
      GoRoute(
        path: AppRoute.settings.path,
        name: AppRoute.settings.name,
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );
});
