import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../consts/custom_colors.dart';
import '../l10n/app_localizations.dart';
import 'logic/validators.dart';
import 'login.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  static String path = '/signUp';
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
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
      return AppLocalizations.of(context)!.requiredField;
    }
    return null;
  }

  String? ageValidator() {
    if (int.tryParse(_ageController.text.trim()) != null &&
        int.parse(_ageController.text.trim()) > 0) {
      return null;
    }
    return AppLocalizations.of(context)!.insertaValidAge;
  }

  Future<void> onRegisteredButtonClick() async {
    setState(() {
      _nameError = Validators.validateName(
        context,
        _nameController.text.trim(),
      );
      _ageError = Validators.validateAge(context, _ageController.text.trim());
      _emailError = Validators.validateEmail(
        context,
        _emailController.text.trim(),
      );
      _passwordError = Validators.validatePassword(
        context,
        _passwordController.text.trim(),
      );
    });

    if (_nameError != null ||
        _passwordError != null ||
        _emailError != null ||
        _ageError != null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final AppLocalizations loc = AppLocalizations.of(context)!;

    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = loc.emailAlreadyInUse;
          break;
        case 'invalid-email':
          errorMessage = loc.invalidEmail;
          setState(() {
            _emailError = errorMessage;
          });
          break;
        case 'weak-password':
          errorMessage = _passwordError!;
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      AppLocalizations.of(context)!.signUp,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 80,
                        color: CustomColors.mainYellow,
                      ),
                    ),
                    const SizedBox(height: 50),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: CustomColors.inputFill,
                        errorText: _nameError,
                        hintText: AppLocalizations.of(
                          context,
                        )!.firstAndLastName,
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
                        filled: true,
                        fillColor: CustomColors.inputFill,
                        errorText: _ageError,
                        hintText: AppLocalizations.of(context)!.age,
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
                        filled: true,
                        fillColor: CustomColors.inputFill,
                        errorText: _emailError,
                        hintStyle: const TextStyle(fontWeight: FontWeight.bold),
                        hintText: AppLocalizations.of(context)!.email,
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: CustomColors.inputFill,
                        errorText: _passwordError,
                        hintText: AppLocalizations.of(context)!.password,
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
                          backgroundColor: CustomColors.mainYellow,
                          foregroundColor: CustomColors.black,
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
                                  color: CustomColors.black,
                                ),
                              )
                            : Text(AppLocalizations.of(context)!.signUp),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.alreadyHaveAnAccountPress,
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 20,
                            color: CustomColors.white,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go(LoginScreen.path),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 20,
                            ),
                            AppLocalizations.of(context)!.here,
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
      ),
    );
  }
}
