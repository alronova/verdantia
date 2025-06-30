import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:verdantia/features/garden/view/garden_screen.dart';
// pages
import '../landing_page.dart';
import '../features/auth/login_page.dart';
import '../features/auth/signup_page.dart';

final GoRouter router = GoRouter(routes: <RouteBase>[
  GoRoute(
    path: '/',
    builder: (BuildContext context, GoRouterState state) {
      return const LandingPage();
    },
  ),
  GoRoute(
    path: '/login',
    builder: (BuildContext context, GoRouterState state) {
      return const LoginPage();
    },
  ),
  GoRoute(
    path: '/signup',
    builder: (BuildContext context, GoRouterState state) {
      return const SignupPage();
    },
  ),
  GoRoute(
    path: '/garden',
    builder: (BuildContext context, GoRouterState state) {
      return const GardenScreen();
    },
  ),
]);
