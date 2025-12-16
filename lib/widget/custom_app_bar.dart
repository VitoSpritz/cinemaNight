import 'package:flutter/material.dart';

import '../consts/custom_colors.dart';
import '../consts/custom_typography.dart';
import '../consts/sizes.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData? rightIcon;
  final Future<void> Function()? onRightIconTap;
  final Widget? actionButton;
  final Function(String?)? onSearch;
  final bool hideMainIcon;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onSearch,
    this.actionButton,
    this.onRightIconTap,
    this.rightIcon,
    this.hideMainIcon = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(40.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 40,
      backgroundColor: CustomColors.mainYellow,
      iconTheme: const IconThemeData(color: CustomColors.text),
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: <Widget>[
            if (!hideMainIcon)
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
            if (rightIcon != null)
              Padding(
                padding: const EdgeInsets.only(right: 38.0),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: onRightIconTap,
                  child: Icon(
                    rightIcon,
                    size: Sizes.iconMedium,
                    color: CustomColors.text,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
