import 'package:flutter/material.dart';

import 'login.dart';
import 'router/router.dart';

class SignUpScreen extends StatefulWidget {
  static String path = '/signUp';
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String? _emailError;
  String? _ageError;
  String? _passwordError;
  String? _nameError;

  String? nameValidator() {
    if (_nameController.text.isNotEmpty) {
      return null;
    }
    return "Campo obbligatorio";
  }

  String? passwordValidator() {
    if (_passwordController.text.length > 8) {
      return null;
    }
    return "La password deve contenere almeno 9 caratteri";
  }

  String? emailValidator() {
    if (_emailController.text.contains('@')) {
      return null;
    }
    return "Inserire una email valida";
  }

  String? ageValidator() {
    if (int.tryParse(_ageController.text) != null &&
        int.parse(_ageController.text) > 0) {
      return null;
    }
    return "Inserire un'età valida";
  }

  void onRegisteredButtonClick() {
    setState(() {
      _nameError = nameValidator();
      _passwordError = passwordValidator();
      _emailError = emailValidator();
      _ageError = ageValidator();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 90),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    "Sign Up",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 80),
                  ),

                  const SizedBox(height: 50),

                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      errorText: _nameError,
                      hintText: 'First and Last Name',
                      hintStyle: const TextStyle(fontWeight: FontWeight.bold),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: _ageController,
                    decoration: InputDecoration(
                      errorText: _ageError,
                      hintText: 'Age',
                      hintStyle: const TextStyle(fontWeight: FontWeight.bold),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: _emailController,
                    obscureText: false,
                    decoration: InputDecoration(
                      errorText: _emailError,
                      hintStyle: const TextStyle(fontWeight: FontWeight.bold),
                      hintText: 'Email',
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      errorText: _passwordError,
                      hintText: 'password',
                      hintStyle: const TextStyle(fontWeight: FontWeight.bold),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => onRegisteredButtonClick(),

                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.amberAccent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(10),
                        ),
                      ),
                      child: const Text("Sign Up"),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: <Widget>[
                      const Text(
                        "already have an account? Press ",
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 20,
                        ),
                      ),
                      TextButton(
                        onPressed: () => router.push(const LoginScreen().path),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 20,
                          ),
                          "here",
                        ),
                      ),
                    ],
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
