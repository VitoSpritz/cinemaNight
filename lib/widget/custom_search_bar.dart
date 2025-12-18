import 'package:flutter/material.dart';

import '../consts/custom_colors.dart';
import '../consts/custom_typography.dart';
import '../helpers/app_palette.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final Function()? onSubmitFunction;
  final String hintText;

  const CustomSearchBar({
    super.key,
    required this.searchController,
    required this.onSubmitFunction,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: searchController,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: CustomTypography.body.copyWith(
          color: AppPalette.of(context).textColors.simpleText,
        ),
        fillColor: CustomColors.white,
        filled: true,
        prefixIcon: const Icon(Icons.search, color: CustomColors.lightBlue),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(),
        ),
      ),
      style: CustomTypography.body.copyWith(
        color: AppPalette.of(context).textColors.simpleText,
      ),
      onTapOutside: (PointerDownEvent event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      onSubmitted: (String value) {
        if (searchController.text.isNotEmpty &&
            searchController.text.trim().isNotEmpty) {
          onSubmitFunction?.call();
        }
      },
    );
  }
}
