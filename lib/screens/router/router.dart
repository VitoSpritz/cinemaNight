import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../consts/global_state.dart';
import '../../model/date_model.dart';
import '../../providers/auth.dart';
import '../../widget/custom_bottom_bar.dart';
import '../account.dart';
import '../chats.dart';
import '../group_chat.dart';
import '../home.dart';
import '../login.dart';
import '../review_info.dart';
import '../review_list.dart';
import '../sign_up.dart';
import '../splash_screen.dart';

GoRouter? _previousRouter;
final GlobalKey<NavigatorState> _shellNavigatorAKey = GlobalKey<NavigatorState>(
  debugLabel: 'shellA',
);
final GlobalKey<NavigatorState> _shellNavigatorBKey = GlobalKey<NavigatorState>(
  debugLabel: 'shellB',
);
final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
  final User? user = ref.watch(authProvider);

  return GoRouter(
    initialLocation:
        _previousRouter?.routerDelegate.currentConfiguration.fullPath,
    navigatorKey: GlobalState.navigatorKey,
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder:
            (
              Object? context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) {
              return CustomBottomBar(navigationShell: navigationShell);
            },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            navigatorKey: _shellNavigatorAKey,
            routes: <RouteBase>[
              GoRoute(
                path: Account.path,
                builder: (BuildContext context, GoRouterState state) =>
                    const Account(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: ReviewList.path,
                builder: (BuildContext context, GoRouterState state) =>
                    const ReviewList(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorBKey,
            routes: <RouteBase>[
              GoRoute(
                path: Chats.path,
                builder: (BuildContext context, GoRouterState state) =>
                    const Chats(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/home',
                builder: (BuildContext context, GoRouterState state) =>
                    const HomeScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: ReviewInfo.path,
        name: 'reviewInfo',
        builder: (BuildContext context, GoRouterState state) {
          final String reviewId = state.pathParameters['reviewId']!;
          return ReviewInfo(reviewId: reviewId);
        },
      ),
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
        path: ReviewList.path,
        builder: (BuildContext context, GoRouterState state) =>
            const ReviewList(),
      ),
      GoRoute(
        path: GroupChat.path,
        name: 'groupChat',
        builder: (BuildContext context, GoRouterState state) {
          final String? chatId = state.uri.queryParameters['chatId'];
          final DateTime maxDate = state.uri.queryParameters['maxDate'] != null
              ? const DateTimeSerializer().fromJson(
                  state.uri.queryParameters['maxDate']!,
                )
              : DateTime.now();

          return GroupChat(
            chatId: chatId!,
            maxDate: maxDate,
          );
        },
      ),
    ],
  );
});
