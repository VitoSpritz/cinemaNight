import 'package:firebase_auth/firebase_auth.dart';
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
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _emailError;
  String? _passwordError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener;
    _passwordController.addListener;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? validateEmail() {
    if (_emailController.text.isEmpty) {
      return null;
    }
    if (_emailController.text.contains('@')) {
      return null;
    }
    return "La email non è formattata nel modo giusto";
  }

  String? validatePassword() {
    if (_passwordController.text.length > 8) {
      return null;
    }
    return "La passowrd non è abbastanza lunga";
  }

  Future<void> onSubmitButtonClick() async {
    setState(() {
      _emailError = validateEmail();
      _passwordError = validatePassword();
    });

    if (_emailError != null || _passwordError != null) {
      return;
    }

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inserisci email e password')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Nessun utente trovato';
          break;
        case 'invalid-credential':
          errorMessage = 'Credenziali non valide';
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
              child: const Text(
                "Login",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 80),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  icon: const Icon(Icons.email),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  labelText: "Email",
                  errorText: _emailError,
                ),
              ),
            ),
            const SizedBox(height: 69),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  icon: const Icon(Icons.password),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  label: const Text(
                    'Password',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  errorText: _passwordError,
                ),
              ),
            ),
            const SizedBox(height: 69),
            FractionallySizedBox(
              widthFactor: 0.85,
              child: FilledButton(
                onPressed: () => onSubmitButtonClick(),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.amberAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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
                    : const Text("Login"),
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
