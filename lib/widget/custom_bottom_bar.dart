import 'package:flutter/material.dart';

import '../consts/custom_colors.dart';
import '../screens/account.dart';
import '../screens/chats.dart';
import '../screens/list.dart';
import '../screens/router/router.dart';
import 'custom_icon_button.dart';

class CustomBottomBar extends StatefulWidget {
  final String activePage;

  const CustomBottomBar({super.key, required this.activePage});

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar> {
  late String _activePage;

  @override
  void initState() {
    super.initState();
    _activePage = widget.activePage;
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 66,
      color: const Color(0xFFF7B921),
      elevation: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          CustomIconButton(
            icon: Icons.account_box_rounded,
            color: _activePage == "account"
                ? CustomColors.white
                : CustomColors.black,
            onTap: () {
              router.go(Account.path);
            },
          ),
          CustomIconButton(
            icon: Icons.list,
            color: _activePage == "list"
                ? CustomColors.white
                : CustomColors.black,
            onTap: () {
              router.go(List.path);
            },
          ),
          CustomIconButton(
            icon: Icons.chat,
            color: _activePage == "chats"
                ? CustomColors.white
                : CustomColors.black,
            onTap: () {
              router.go(Chats.path);
            },
          ),
        ],
      ),
    );
  }
}
