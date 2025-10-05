import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../consts/regex.dart';
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
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _emailError;
  String? _ageError;
  String? _passwordError;
  String? _nameError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener;
    _passwordController.addListener;
    _ageController.addListener;
    _nameController.addListener;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String? nameValidator() {
    if (_nameController.text.trim().isEmpty) {
      return "Campo obbligatorio";
    }
    return null;
  }

  String? passwordValidator() {
    String password = _passwordController.text.trim();

    if (password.isEmpty) {
      return 'La password è un campo necessario';
    }
    if (Regex.passwordRegex.hasMatch(password)) {
      return null;
    }
    return 'Deve contente 8 caratteri, 1 maiuscola e 1 numero';
  }

  String? emailValidator() {
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      return 'La email è un campo necessario';
    }
    if (Regex.emailRegex.hasMatch(email)) {
      return null;
    }
    return "Inserire una email valida";
  }

  String? ageValidator() {
    if (int.tryParse(_ageController.text.trim()) != null &&
        int.parse(_ageController.text.trim()) > 0) {
      return null;
    }
    return "Inserire un'età valida";
  }

  Future<void> onRegisteredButtonClick() async {
    setState(() {
      _nameError = nameValidator();
      _ageError = ageValidator();
      _emailError = emailValidator();
      _passwordError = passwordValidator();
    });

    if (_nameError != null ||
        _passwordError != null ||
        _emailError != null ||
        _ageError != null) {
      _passwordController.clear();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = "Email già in uso";
          break;
        case 'invalid-email':
          errorMessage = 'Email non valida';
          setState(() {
            _emailError = errorMessage;
          });
          break;
        case 'weak-password':
          errorMessage = _passwordError!;
          break;
        default:
          errorMessage = 'Errore di autenticazione: ${e.message}';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
                      hintText: 'Password',
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
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Text("Sing up"),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: <Widget>[
                      const Text(
                        "Already have an account? Press ",
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 20,
                        ),
                      ),
                      TextButton(
                        onPressed: () => router.go(LoginScreen.path),
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
