import 'package:flutter/material.dart';

import '../../consts/regex.dart';
import '../../l10n/app_localizations.dart';

class Validators {
  Validators._();

  static String? validatePassword(BuildContext context, String password) {
    if (password.isEmpty) {
      return AppLocalizations.of(context)!.passwordIsRequired;
    }
    if (!Regex.passwordRegex.hasMatch(password)) {
      return AppLocalizations.of(context)!.passwordMinimalRequirements;
    }
    return null;
  }

  static String? validateEmail(BuildContext context, String email) {
    if (email.isEmpty) {
      return AppLocalizations.of(context)!.emailIsRequired;
    }
    if (!Regex.emailRegex.hasMatch(email)) {
      return AppLocalizations.of(context)!.insertaValidEmail;
    }
    return null;
  }

  static String? validateName(BuildContext context, String name) {
    if (name.isEmpty) {
      return AppLocalizations.of(context)!.requiredField;
    }
    return null;
  }

  static String? validateAge(BuildContext context, String age) {
    final int? parsedAge = int.tryParse(age);
    if (parsedAge == null || parsedAge <= 0) {
      return AppLocalizations.of(context)!.insertaValidAge;
    }
    return null;
  }
}
