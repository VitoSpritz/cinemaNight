import 'package:flutter/material.dart';

import 'router/router.dart';
import 'sign_up.dart';

class LoginScreen extends StatelessWidget {
  final String path = '/login';

  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 90),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: const Text(
                "Login",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 80),
              ),
            ),
            const SizedBox(height: 50),

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

            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
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

            SizedBox(
              width: MediaQuery.of(context).size.width * 0.80,

              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    "Not registered? Press ",
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 24,
                    ),
                  ),

                  const SizedBox(height: 200),

                  TextButton(
                    onPressed: () => router.push(SignUpScreen.path),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 24,
                      ),
                      "here",
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
