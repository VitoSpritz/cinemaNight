// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get homePage => 'Home Page';

  @override
  String get confirmLogout => 'Confirm logout';

  @override
  String get areYouSureYouWantToQuit => 'Are you sure you want to quit?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get welcome => 'Welcome';

  @override
  String get goToHome => 'Go to the home page';

  @override
  String currentUserString(String email) {
    return 'User: $email';
  }

  @override
  String get unknown => 'unknown';

  @override
  String get invalidCredential => 'Invalid credential';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String authenticationError(String errorCode) {
    return 'Authentication error: $errorCode';
  }

  @override
  String get loginString => 'Login';

  @override
  String get loginButton => 'Login';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get notRegisteredPress => 'Not registered yet? Press ';

  @override
  String get here => 'here';

  @override
  String get requiredField => 'Required field';

  @override
  String get insertaValidAge => 'Insert valid age';

  @override
  String get emailAlreadyInUse => 'Email already in use';

  @override
  String error(String errorMessage) {
    return 'Error: $errorMessage';
  }

  @override
  String get signUp => 'Sign up';

  @override
  String get firstAndLastName => 'First and last name';

  @override
  String get age => 'Age';

  @override
  String get alreadyHaveAnAccountPress => 'Already have an account? Press ';

  @override
  String get passwordIsRequired => 'Password is required';

  @override
  String get passwordMinimalRequirements =>
      'Password must contain at least 8 characters, 1 capital letter and 1 number';

  @override
  String get emailIsRequired => 'Email is required';

  @override
  String get insertaValidEmail => 'Insert a valid email';

  @override
  String get account => 'Account';

  @override
  String get reviews => 'Reviews';

  @override
  String get home => 'Home';

  @override
  String get chats => 'Chats';

  @override
  String get requestApiLanguage => 'en-EN';
}
