import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login.dart';
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
              final bool? isLoggingOut = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Conferma logout'),
                    content: const Text('Sei sicuro di voler uscire?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Si'),
                      ),
                    ],
                  );
                },
              );

              if (isLoggingOut == true) {
                await FirebaseAuth.instance.signOut();
                router.go(LoginScreen.path);
              }
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
