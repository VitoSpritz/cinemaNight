import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../home.dart';
import '../login.dart';
import '../sign_up.dart';
import '../splash_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: const SplashScreen().path,
  routes: <RouteBase>[
    GoRoute(
      path: const SplashScreen().path,
      builder: (BuildContext context, GoRouterState state) =>
          const SplashScreen(),
    ),
    GoRoute(
      path: const HomeScreen().path,
      builder: (BuildContext context, GoRouterState state) =>
          const HomeScreen(),
    ),
    GoRoute(
      path: const LoginScreen().path,
      builder: (BuildContext context, GoRouterState state) =>
          const LoginScreen(),
    ),
    GoRoute(
      path: SignUpScreen.path,
      builder: (BuildContext context, GoRouterState state) =>
          const SignUpScreen(),
    ),
  ],
);
