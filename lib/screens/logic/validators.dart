import '../../consts/regex.dart';

class Validators {
  Validators._();

  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'La password è un campo necessario';
    }
    if (!Regex.passwordRegex.hasMatch(password)) {
      return 'Deve contenere 8 caratteri, 1 maiuscola e 1 numero';
    }
    return null;
  }

  static String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'La email è un campo necessario';
    }
    if (!Regex.emailRegex.hasMatch(email)) {
      return 'Inserire una email valida';
    }
    return null;
  }

  static String? validateName(String name) {
    if (name.isEmpty) {
      return 'Campo obbligatorio';
    }
    return null;
  }

  static String? validateAge(String age) {
    final int? parsedAge = int.tryParse(age);
    if (parsedAge == null || parsedAge <= 0) {
      return "Inserire un'età valida";
    }
    return null;
  }
}
