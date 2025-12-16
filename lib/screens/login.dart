import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../consts/custom_colors.dart';
import '../consts/custom_typography.dart';
import '../helpers/app_palette.dart';
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
            backgroundColor: CustomColors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.error(e.toString())),
            backgroundColor: CustomColors.red,
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
        decoration: BoxDecoration(
          gradient: AppPalette.of(context).backgroudColor.defaultColor,
        ),
        child: CustomScrollView(
          slivers: <Widget>[
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.1,
                ),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 16.0,
                      ),
                      child: Text(
                        textAlign: TextAlign.center,
                        AppLocalizations.of(context)!.loginString,
                        style: CustomTypography.mainTitle.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 60,
                          color: CustomColors.mainYellow,
                        ),
                      ),
                    ),
                    const Spacer(),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: CustomColors.inputFill,
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        label: Text(
                          AppLocalizations.of(context)!.email,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        errorText: _emailError,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onTapOutside: (PointerDownEvent event) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                    ),
                    const SizedBox(height: 32),
                    TextField(
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
                      onTapOutside: (PointerDownEvent event) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
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
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RichText(
                        textAlign: TextAlign.center,
                        textScaler: MediaQuery.of(context).textScaler,
                        text: TextSpan(
                          children: <InlineSpan>[
                            TextSpan(
                              text: AppLocalizations.of(
                                context,
                              )!.notRegisteredPress,
                              style: CustomTypography.titleM.copyWith(
                                color: CustomColors.white,
                              ),
                            ),
                            TextSpan(
                              text: AppLocalizations.of(context)!.here,
                              style: CustomTypography.titleM.copyWith(
                                color: CustomColors.mainYellow,
                                decoration: TextDecoration.underline,
                                decorationColor: CustomColors.mainYellow,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => context.go(SignUpScreen.path),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
