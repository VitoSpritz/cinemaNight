import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../consts/global_state.dart';
import '../../providers/auth.dart';
import '../account.dart';
import '../chats.dart';
import '../home.dart';
import '../list.dart';
import '../login.dart';
import '../sign_up.dart';
import '../splash_screen.dart';

// We need to have access to the previous location of the router. Otherwise, we would start from '/' on rebuild
GoRouter? _previousRouter;

final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
  final User? user = ref.watch(authProvider);

  return GoRouter(
    initialLocation:
        _previousRouter?.routerDelegate.currentConfiguration.fullPath,
    navigatorKey: GlobalState.navigatorKey,
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
        redirect: (BuildContext context, GoRouterState state) {
          if (user == null) {
            context.go(LoginScreen.path);
          }
          return null;
        },
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
});
