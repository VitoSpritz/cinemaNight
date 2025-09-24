import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';

void main() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: SplashScreen()),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: Text('Hello World!'))),
    );
  }
}
