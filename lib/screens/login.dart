import 'package:flutter/material.dart';

import 'router/router.dart';
import 'sign_up.dart';

class LoginScreen extends StatefulWidget {
  static String path = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      final String text = _emailController.text.toLowerCase();
      _emailController.value = _emailController.value.copyWith(
        text: text,
        selection: TextSelection(
          baseOffset: text.length,
          extentOffset: text.length,
        ),
        composing: TextRange.empty,
      );
    });

    _passwordController.addListener(() {
      final String text = _passwordController.text.toLowerCase();
      _passwordController.value = _passwordController.value.copyWith(
        text: text,
        selection: TextSelection(
          baseOffset: text.length,
          extentOffset: text.length,
        ),
        composing: TextRange.empty,
      );
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
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
            const SizedBox(height: 16),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextFormField(
                controller: _emailController,
                validator: (String? value) {
                  return (value != null && value.contains('@'))
                      ? null
                      : "Il valore non contiene una @";
                },
                decoration: const InputDecoration(
                  icon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  labelText: "Email",
                ),
              ),
            ),
            const SizedBox(height: 69),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextFormField(
                controller: _passwordController,
                obscureText: true,
                validator: (String? value) {
                  return (value != null && value.length > 7)
                      ? null
                      : "La password è troppo corta";
                },
                decoration: const InputDecoration(
                  icon: Icon(Icons.password),
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
                onPressed: () => router.push(LoginScreen.path),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.amberAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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
