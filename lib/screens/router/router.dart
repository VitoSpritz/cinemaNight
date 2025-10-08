import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../auth/authenticator.dart';
import '../account.dart';
import '../chats.dart';
import '../home.dart';
import '../list.dart';
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

    if (isAuthenticated &&
        (currentLocation == LoginScreen.path ||
            currentLocation == SignUpScreen.path)) {
      return Chats.path;
    }

    if (!isAuthenticated &&
        currentLocation != LoginScreen.path &&
        currentLocation != SignUpScreen.path) {
      return LoginScreen.path;
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
    GoRoute(
      path: Chats.path,
      builder: (BuildContext context, GoRouterState state) => const Chats(),
    ),
    GoRoute(
      path: Account.path,
      builder: (BuildContext context, GoRouterState state) => const Account(),
    ),
    GoRoute(
      path: List.path,
      builder: (BuildContext context, GoRouterState state) => const List(),
    ),
  ],
);
