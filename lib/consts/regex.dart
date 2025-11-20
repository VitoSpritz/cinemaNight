abstract class Regex {
  static RegExp passwordRegex = RegExp(r'^(?=.*[a-zA-Z0-9]).{6,}$');

  static RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
}
