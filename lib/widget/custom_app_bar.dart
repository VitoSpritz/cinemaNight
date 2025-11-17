import 'package:flutter/material.dart';

import '../consts/custom_colors.dart';
import '../consts/custom_typography.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  final Widget? actionButton;
  final Function(String?)? onSearch;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onSearch,
    this.actionButton,
  });

  @override
  Size get preferredSize => const Size.fromHeight(40.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 40,
      backgroundColor: CustomColors.mainYellow,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Image.asset('assets/images/namelesslogo.png', width: 24),
            ),
            Expanded(
              child: Center(
                child: Text(
                  title,
                  style: CustomTypography.mainTitle.copyWith(
                    color: CustomColors.text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            actionButton ?? const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }
}
