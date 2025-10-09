import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../consts/custom_colors.dart';
import '../providers/auth.dart';
import 'home.dart';
import 'login.dart';

class SplashScreen extends ConsumerStatefulWidget {
  static String path = '/';

  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        final User? user = ref.read(authProvider);
        if (user == null) {
          context.go(LoginScreen.path);
        } else {
          context.go(HomeScreen.path);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.lightBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/logo.png', width: 200),
            const SizedBox(height: 20),
            CircularProgressIndicator(color: CustomColors.white),
          ],
        ),
      ),
    );
  }
}
