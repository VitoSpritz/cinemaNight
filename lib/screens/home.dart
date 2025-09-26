import 'package:flutter/material.dart';

import 'router/router.dart';

class HomeScreen extends StatelessWidget {
  final String path = '/home';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Home Page",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        alignment: Alignment.center,
        child: ElevatedButton(
          onPressed: () => router.push("/home"),
          child: const Text("Go to home"),
        ),
      ),
    );
  }
}
