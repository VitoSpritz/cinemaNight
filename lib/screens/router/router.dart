import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../splash_screen.dart';

final GoRouter _router = GoRouter(
  initialLocation: '/splash',
  routes: <RouteBase>[
    GoRoute(path: '/splash', builder: (BuildContext contex, GoRouterState state) => SplashScreen())
  ]
);

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}