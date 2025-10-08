import 'package:flutter/material.dart';

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
      backgroundColor: const Color(0xFFF7B921),
      titleSpacing: 0,
      title: Row(
        children: <Widget>[
          Image.asset('assets/images/logo.png', width: 60),
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
              size: 45,
              color: const Color(0xFF002F4E),
            )
          else
            const SizedBox(width: 60),
        ],
      ),
    );
  }
}
