// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

import '../consts/custom_colors.dart';

class AppPalette {
  AppPalette._(this.context) {
    final Brightness brightness = Theme.of(context).brightness;
    isDarkMode = (brightness == Brightness.dark);

    // Initialize all color groups with dark mode flag
    textColors = _TextColors(isDarkMode);
    backgroudColor = _BackgroudColor(isDarkMode);
    badgeColor = _BadgeColor(isDarkMode);
    messageBackgroundColor = _MessageBackground(isDarkMode);
    pickerTheme = _PickerTheme(isDarkMode);
  }

  static AppPalette of(BuildContext context) {
    return AppPalette._(context);
  }

  final BuildContext context;
  late final bool isDarkMode;

  // Backgrounds
  late final _TextColors textColors;
  late final _BackgroudColor backgroudColor;
  late final _BadgeColor badgeColor;
  late final _MessageBackground messageBackgroundColor;
  late final _PickerTheme pickerTheme;
}

class _TextColors {
  _TextColors(this.isDarkMode);

  final bool isDarkMode;

  Color get defaultColor =>
      isDarkMode ? CustomColors.white : CustomColors.black;
  Color get simpleText => CustomColors.black;
}

class _BackgroudColor {
  _BackgroudColor(this.isDarkMode);

  final bool isDarkMode;

  get defaultColor => isDarkMode
      ? const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: <double>[0, 0.19, 0.41, 1.0],
          colors: <Color>[
            Color(0xFF5264DE),
            Color(0xFF212C77),
            Color(0xFF050031),
            Color(0xFF050031),
          ],
        )
      : const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFFFFFFFF), Color(0xFF90CAF9)],
        );
}

class _BadgeColor {
  _BadgeColor(this.isDarkMode);

  final bool isDarkMode;

  Color get defaultColor =>
      isDarkMode ? CustomColors.lightYellow : CustomColors.lightBlue;
}

class _MessageBackground {
  _MessageBackground(this.isDarkMode);

  final bool isDarkMode;

  Color get chatMessageBackground => isDarkMode
      ? CustomColors.inputFill.withValues(alpha: 0.8)
      : CustomColors.white.withValues(alpha: 0.8);
}

class _PickerTheme {
  _PickerTheme(this.isDarkMode);

  final bool isDarkMode;

  ColorScheme get colorScheme => isDarkMode
      ? const ColorScheme.dark(
          primary: CustomColors.lightBlue,
          onPrimary: CustomColors.white,
          onSurface: CustomColors.white,
        )
      : const ColorScheme.light(
          primary: CustomColors.lightBlue,
          onPrimary: CustomColors.white,
          onSurface: CustomColors.black,
        );
}
