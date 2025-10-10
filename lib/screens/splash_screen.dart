import 'dart:async';

import 'package:flutter/material.dart';

import '../consts/custom_colors.dart';
import 'login.dart';
import 'router/router.dart';

class SplashScreen extends StatefulWidget {
  static String path = '/splash';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        router.go(LoginScreen.path);
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
