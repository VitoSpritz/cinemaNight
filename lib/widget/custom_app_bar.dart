import 'package:flutter/material.dart';

import '../consts/custom_colors.dart';
import 'custom_icon_button.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool searchEnabled;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.searchEnabled,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 45,
      backgroundColor: CustomColors.mainYellow,
      titleSpacing: 0,
      title: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 12, bottom: 12),
            child: Image.asset('assets/images/namelesslogo.png', width: 40),
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF002F4E),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (searchEnabled == true)
            CustomIconButton(
              icon: Icons.search,
              onTap: () {},
              iconSize: 45,
              color: CustomColors.text,
            )
          else
            const SizedBox(width: 60),
        ],
      ),
    );
  }
}
