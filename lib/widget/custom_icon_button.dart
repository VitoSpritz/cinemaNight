import 'package:flutter/material.dart';

import '../consts/custom_colors.dart';

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double? iconSize;
  final Color color;
  final double? padding;

  const CustomIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.iconSize = 24,
    this.color = CustomColors.black,
    this.padding = 16,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(padding!),
        child: Icon(icon, size: iconSize, color: color),
      ),
    );
  }
}
