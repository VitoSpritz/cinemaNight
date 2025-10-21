import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../consts/custom_colors.dart';
import '../l10n/app_localizations.dart';
import 'logic/validators.dart';
import 'sign_up.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static String path = '/login';

  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _emailError;
  String? _passwordError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void clearFieldsOnError() {
    _emailController.clear();
    _passwordController.clear();
  }

  Future<void> onSubmitButtonClick() async {
    setState(() {
      _emailError = Validators.validateEmail(
        context,
        _emailController.text.trim(),
      );
      _passwordError = Validators.validatePassword(
        context,
        _passwordController.text.trim(),
      );
    });

    if (_emailError != null || _passwordError != null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final AppLocalizations loc = AppLocalizations.of(context)!;

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'invalid-credential':
          errorMessage = loc.invalidCredential;
          break;
        case 'invalid-email':
          errorMessage = loc.invalidEmail;
          break;
        default:
          errorMessage = AppLocalizations.of(
            context,
          )!.authenticationError(e.code);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: CustomColors.errorMessage,
          ),
        );
        clearFieldsOnError();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.error(e.toString())),
            backgroundColor: CustomColors.errorMessage,
          ),
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
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: <double>[0, 0.19, 0.41, 1.0],
            colors: <Color>[
              Color(0xFF5264DE),
              Color(0xFF212C77),
              Color(0xFF050031),
              Color(0xFF050031),
            ],
          ),
        ),
        child: Center(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 90),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Text(
                  AppLocalizations.of(context)!.loginString,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 80,
                    color: CustomColors.mainYellow,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: CustomColors.inputFill,
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    labelText: AppLocalizations.of(context)!.email,
                    errorText: _emailError,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              const SizedBox(height: 69),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: CustomColors.inputFill,
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    label: Text(
                      AppLocalizations.of(context)!.password,
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
                    backgroundColor: CustomColors.mainYellow,
                    foregroundColor: CustomColors.black,
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
                            color: CustomColors.black,
                          ),
                        )
                      : Text(AppLocalizations.of(context)!.loginButton),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      AppLocalizations.of(context)!.notRegisteredPress,
                      style: TextStyle(
                        color: CustomColors.white,
                        fontWeight: FontWeight.normal,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 200),
                    TextButton(
                      onPressed: () => context.go(SignUpScreen.path),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 24,
                        ),
                        AppLocalizations.of(context)!.here,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
