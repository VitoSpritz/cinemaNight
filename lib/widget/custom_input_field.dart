import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../consts/custom_colors.dart';
import '../consts/custom_typography.dart';
import '../helpers/app_palette.dart';

class CustomInputField extends ConsumerWidget {
  final TextEditingController controller;
  final String fieldName;
  final String? hintText;
  final TextInputType textType;
  final bool hidden;
  final String? errorMessage;

  const CustomInputField({
    super.key,
    required this.fieldName,
    required this.controller,
    this.textType = TextInputType.text,
    this.hidden = false,
    this.errorMessage,
    this.hintText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
          child: Text(
            fieldName,
            style: CustomTypography.bodySmall.copyWith(
              color: AppPalette.of(context).textColors.simpleText,
            ),
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: textType,
          obscureText: hidden,
          style: TextStyle(color: AppPalette.of(context).textColors.simpleText),
          decoration: InputDecoration(
            hintStyle: CustomTypography.bodySmall.copyWith(
              color: AppPalette.of(context).textColors.simpleText,
            ),
            filled: true,
            fillColor: CustomColors.white.withValues(alpha: 0.7),
            hintText: hintText ?? fieldName,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                width: 1,
                color: errorMessage != null
                    ? CustomColors.red
                    : CustomColors.black,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                width: 1,
                color: errorMessage != null
                    ? CustomColors.red
                    : CustomColors.black,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                width: 1,
                color: errorMessage != null
                    ? CustomColors.red
                    : CustomColors.black,
              ),
            ),
          ),
          onTapOutside: (PointerDownEvent event) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
        ),
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsetsGeometry.symmetric(
              horizontal: 8,
              vertical: 2,
            ),
            child: Text(
              errorMessage!,
              style: CustomTypography.caption.copyWith(color: CustomColors.red),
            ),
          ),
      ],
    );
  }
}
