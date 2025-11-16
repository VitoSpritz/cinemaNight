import 'package:flutter/material.dart';

abstract class CustomTypography {
  static TextStyle get mainTitle =>
      const TextStyle(fontWeight: FontWeight.w400, fontSize: 32);

  static TextStyle get titleXL =>
      const TextStyle(fontWeight: FontWeight.w400, fontSize: 24);

  static TextStyle get titleM =>
      const TextStyle(fontWeight: FontWeight.w400, fontSize: 18);

  static TextStyle get bodyBold =>
      const TextStyle(fontWeight: FontWeight.w600, fontSize: 16);

  static TextStyle get body =>
      const TextStyle(fontWeight: FontWeight.w400, fontSize: 16);

  static TextStyle get bodySmall =>
      const TextStyle(fontWeight: FontWeight.w400, fontSize: 14);

  static TextStyle get bodySmallBold =>
      const TextStyle(fontWeight: FontWeight.w600, fontSize: 14);

  static TextStyle get caption =>
      const TextStyle(fontWeight: FontWeight.w400, fontSize: 12);

  static TextStyle get captionBolder =>
      const TextStyle(fontWeight: FontWeight.w500, fontSize: 12);

  static TextStyle get minimal =>
      const TextStyle(fontWeight: FontWeight.w400, fontSize: 10);
}
