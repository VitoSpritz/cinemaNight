// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get homePage => 'Home Page';

  @override
  String get confirmLogout => 'Conferma logout';

  @override
  String get areYouSureYouWantToQuit => 'Sei sicuro di voler uscire?';

  @override
  String get yes => 'Si';

  @override
  String get no => 'No';

  @override
  String get welcome => 'Benvenuto';

  @override
  String get goToHome => 'Vai alla pagina principale';

  @override
  String currentUserString(String email) {
    return 'Utente: $email';
  }

  @override
  String get unknown => 'sconosciuto';

  @override
  String get invalidCredential => 'Credenziali non valide';

  @override
  String get invalidEmail => 'Email non valida';

  @override
  String authenticationError(String errorCode) {
    return 'Errore di autenticazione: $errorCode';
  }

  @override
  String get loginString => 'Login';

  @override
  String get loginButton => 'Accedi';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get notRegisteredPress => 'Non hai un account? Premi ';

  @override
  String get here => 'qui';

  @override
  String get requiredField => 'Campo obbligatorio';

  @override
  String get insertaValidAge => 'Inserire un\'età valida';

  @override
  String get emailAlreadyInUse => 'Email già in uso';

  @override
  String error(String errorMessage) {
    return 'Errore: $errorMessage';
  }

  @override
  String get signUp => 'Crea un account';

  @override
  String get firstAndLastName => 'Nome e cognome';

  @override
  String get age => 'Età';

  @override
  String get alreadyHaveAnAccountPress => 'Hai già un account? Premi ';

  @override
  String get passwordIsRequired => 'La password è necessaria';

  @override
  String get passwordMinimalRequirements =>
      'La password deve contenere almeno 8 caratteri, 1 lettera maiuscole e 1 numero';

  @override
  String get emailIsRequired => 'L\'indirizzo email è necessario';

  @override
  String get insertaValidEmail => 'Inserire una email valida';

  @override
  String get account => 'Account';

  @override
  String get reviews => 'Recensioni';

  @override
  String get home => 'Home';

  @override
  String get chats => 'Gruppi';

  @override
  String get requestApiLanguage => 'it-ITA';
}
