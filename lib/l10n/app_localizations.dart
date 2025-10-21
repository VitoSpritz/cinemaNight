import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
  ];

  /// No description provided for @homePage.
  ///
  /// In it, this message translates to:
  /// **'Home Page'**
  String get homePage;

  /// No description provided for @confirmLogout.
  ///
  /// In it, this message translates to:
  /// **'Conferma logout'**
  String get confirmLogout;

  /// No description provided for @areYouSureYouWantToQuit.
  ///
  /// In it, this message translates to:
  /// **'Sei sicuro di voler uscire?'**
  String get areYouSureYouWantToQuit;

  /// No description provided for @yes.
  ///
  /// In it, this message translates to:
  /// **'Si'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In it, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @welcome.
  ///
  /// In it, this message translates to:
  /// **'Benvenuto'**
  String get welcome;

  /// No description provided for @goToHome.
  ///
  /// In it, this message translates to:
  /// **'Vai alla pagina principale'**
  String get goToHome;

  /// No description provided for @currentUserString.
  ///
  /// In it, this message translates to:
  /// **'Utente: {email}'**
  String currentUserString(String email);

  /// No description provided for @unknown.
  ///
  /// In it, this message translates to:
  /// **'sconosciuto'**
  String get unknown;

  /// No description provided for @invalidCredential.
  ///
  /// In it, this message translates to:
  /// **'Credenziali non valide'**
  String get invalidCredential;

  /// No description provided for @invalidEmail.
  ///
  /// In it, this message translates to:
  /// **'Email non valida'**
  String get invalidEmail;

  /// No description provided for @authenticationError.
  ///
  /// In it, this message translates to:
  /// **'Errore di autenticazione: {errorCode}'**
  String authenticationError(String errorCode);

  /// No description provided for @loginString.
  ///
  /// In it, this message translates to:
  /// **'Login'**
  String get loginString;

  /// No description provided for @loginButton.
  ///
  /// In it, this message translates to:
  /// **'Accedi'**
  String get loginButton;

  /// No description provided for @email.
  ///
  /// In it, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In it, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @notRegisteredPress.
  ///
  /// In it, this message translates to:
  /// **'Non hai un account? Premi '**
  String get notRegisteredPress;

  /// No description provided for @here.
  ///
  /// In it, this message translates to:
  /// **'qui'**
  String get here;

  /// No description provided for @requiredField.
  ///
  /// In it, this message translates to:
  /// **'Campo obbligatorio'**
  String get requiredField;

  /// No description provided for @insertaValidAge.
  ///
  /// In it, this message translates to:
  /// **'Inserire un\'età valida'**
  String get insertaValidAge;

  /// No description provided for @emailAlreadyInUse.
  ///
  /// In it, this message translates to:
  /// **'Email già in uso'**
  String get emailAlreadyInUse;

  /// No description provided for @error.
  ///
  /// In it, this message translates to:
  /// **'Errore: {errorMessage}'**
  String error(String errorMessage);

  /// No description provided for @signUp.
  ///
  /// In it, this message translates to:
  /// **'Crea un account'**
  String get signUp;

  /// No description provided for @firstAndLastName.
  ///
  /// In it, this message translates to:
  /// **'Nome e cognome'**
  String get firstAndLastName;

  /// No description provided for @age.
  ///
  /// In it, this message translates to:
  /// **'Età'**
  String get age;

  /// No description provided for @alreadyHaveAnAccountPress.
  ///
  /// In it, this message translates to:
  /// **'Hai già un account? Premi '**
  String get alreadyHaveAnAccountPress;

  /// No description provided for @passwordIsRequired.
  ///
  /// In it, this message translates to:
  /// **'La password è necessaria'**
  String get passwordIsRequired;

  /// No description provided for @passwordMinimalRequirements.
  ///
  /// In it, this message translates to:
  /// **'La password deve contenere almeno 8 caratteri, 1 lettera maiuscole e 1 numero'**
  String get passwordMinimalRequirements;

  /// No description provided for @emailIsRequired.
  ///
  /// In it, this message translates to:
  /// **'L\'indirizzo email è necessario'**
  String get emailIsRequired;

  /// No description provided for @insertaValidEmail.
  ///
  /// In it, this message translates to:
  /// **'Inserire una email valida'**
  String get insertaValidEmail;

  /// No description provided for @account.
  ///
  /// In it, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @reviews.
  ///
  /// In it, this message translates to:
  /// **'Recensioni'**
  String get reviews;

  /// No description provided for @home.
  ///
  /// In it, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @chats.
  ///
  /// In it, this message translates to:
  /// **'Gruppi'**
  String get chats;

  /// No description provided for @requestApiLanguage.
  ///
  /// In it, this message translates to:
  /// **'it-ITA'**
  String get requestApiLanguage;

  /// No description provided for @noReviews.
  ///
  /// In it, this message translates to:
  /// **'Nessuna recensione disponibile'**
  String get noReviews;

  /// No description provided for @addReview.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi una recensione'**
  String get addReview;

  /// No description provided for @title.
  ///
  /// In it, this message translates to:
  /// **'Titolo'**
  String get title;

  /// No description provided for @search.
  ///
  /// In it, this message translates to:
  /// **'Cerca'**
  String get search;

  /// No description provided for @results.
  ///
  /// In it, this message translates to:
  /// **'Risultati:'**
  String get results;

  /// No description provided for @review.
  ///
  /// In it, this message translates to:
  /// **'Recensione'**
  String get review;

  /// No description provided for @save.
  ///
  /// In it, this message translates to:
  /// **'Salva'**
  String get save;

  /// No description provided for @searchAMovie.
  ///
  /// In it, this message translates to:
  /// **'Cerca un film o una serie TV'**
  String get searchAMovie;

  /// No description provided for @changeMovie.
  ///
  /// In it, this message translates to:
  /// **'Cambia il film selezionato'**
  String get changeMovie;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
