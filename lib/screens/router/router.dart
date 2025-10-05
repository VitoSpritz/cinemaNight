import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../auth/authenticator.dart';
import '../home.dart';
import '../login.dart';
import '../sign_up.dart';
import '../splash_screen.dart';

final Authenticator authenticator = Authenticator();

final GoRouter router = GoRouter(
  initialLocation: SplashScreen.path,
  refreshListenable: authenticator,

  redirect: (BuildContext context, GoRouterState state) {
    final bool isAuthenticated = authenticator.isAuthenticated;
    final bool isInitialized = authenticator.isInitialized;
    final String currentLocation = state.matchedLocation;

    if (!isInitialized) {
      return SplashScreen.path;
    }

    if (currentLocation == SplashScreen.path) {
      return isAuthenticated ? HomeScreen.path : LoginScreen.path;
    }

    if (isAuthenticated && currentLocation == LoginScreen.path) {
      return HomeScreen.path;
    }

    return null;
  },
  routes: <RouteBase>[
    GoRoute(
      path: SplashScreen.path,
      builder: (BuildContext context, GoRouterState state) =>
          const SplashScreen(),
    ),
    GoRoute(
      path: HomeScreen.path,
      builder: (BuildContext context, GoRouterState state) =>
          const HomeScreen(),
    ),
    GoRoute(
      path: LoginScreen.path,
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
