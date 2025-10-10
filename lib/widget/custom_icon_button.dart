import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double iconSize;
  final Color color;

  const CustomIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconSize = 60,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 60,
        height: 100,
        child: Icon(icon, size: iconSize, color: color),
      ),
    );
  }
}
