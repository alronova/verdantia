// import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:verdantia/app/app.dart';
import 'package:verdantia/core/utils/garden_utils.dart';
import 'package:verdantia/features/botanica/botanica_screen.dart';
import 'package:verdantia/features/garden/view/plant_action_screen.dart';
import 'package:verdantia/features/garden/view/view_action_screen.dart';
import 'package:verdantia/features/onboarding/onboarding_screen.dart';
// pages
import '../landing_page.dart';
import '../features/auth/login_page.dart';
import '../features/auth/signup_page.dart';
import 'package:verdantia/features/garden/view/garden_screen.dart';
import 'package:verdantia/features/chat/chat_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final loggingIn = state.uri.path == '/login' || state.uri.path == '/signup';

    if (user == null && state.uri.path == '/home') {
      // Redirect unauthenticated users trying to access protected route
      return '/login';
    }

    if (user != null && (state.uri.path == '/' || loggingIn)) {
      // Redirect logged-in users away from login/signup/landing
      return '/home';
    }

    // No redirection
    return null;
  },
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) => const LandingPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupPage(),
    ),
    GoRoute(
      path: '/garden',
      builder: (context, state) => const GardenScreen(),
    ),
    GoRoute(
      path: '/botanica',
      builder: (context, state) => const BotanicaScreen(),
    ),
    GoRoute(
      path: '/chat',
      builder: (context, state) => const ChatScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/plant-action/:action',
      builder: (context, state) {
        final actionStr = state.pathParameters['action']!;
        final action = PlantAction.values.firstWhere(
          (a) => a.name == actionStr,
        );
        return PlantActionScreen(action: action);
      },
    ),
    GoRoute(
      path: '/view-action',
      builder: (context, state) => const ViewActionScreen(),
    ),
  ],
);
