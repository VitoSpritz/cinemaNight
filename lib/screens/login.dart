import 'dart:ui';

import 'package:flutter/material.dart';

import 'router/router.dart';

class LoginScreen extends StatelessWidget {
  final String path = '/login';

  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: const Text(
              "Login",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 80),
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: const TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                label: Text(
                  'Email',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),

          const SizedBox(height: 69),

          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: const TextField(
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                label: Text(
                  'Password',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(height: 69),

          FractionallySizedBox(
            widthFactor: 0.85,
            child: FilledButton(
              onPressed: () => router.push("/login"),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.amberAccent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(10),
                ),
              ),
              child: const Text("Login"),
            ),
          ),
        ],
      ),
    );
  }
}
