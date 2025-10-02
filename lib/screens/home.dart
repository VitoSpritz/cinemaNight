import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'router/router.dart';

class HomeScreen extends StatelessWidget {
  static String path = '/home';

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
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'User: ${FirebaseAuth.instance.currentUser?.email ?? "Unknown"}',
              style: const TextStyle(fontSize: 16),
            ),
            ElevatedButton(
              onPressed: () => router.push(HomeScreen.path),
              child: const Text("Go to home"),
            ),
          ],
        ),
      ),
    );
  }
}
