import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../consts/custom_colors.dart';
import '../screens/account.dart';
import '../screens/chats.dart';
import '../screens/list.dart';
import 'custom_icon_button.dart';

class CustomBottomBar extends ConsumerStatefulWidget {
  final String activePage;

  const CustomBottomBar({super.key, required this.activePage});

  @override
  ConsumerState<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends ConsumerState<CustomBottomBar> {
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
              context.go(Account.path);
            },
          ),
          CustomIconButton(
            icon: Icons.list,
            color: _activePage == "list"
                ? CustomColors.white
                : CustomColors.black,
            onTap: () {
              context.go(List.path);
            },
          ),
          CustomIconButton(
            icon: Icons.chat,
            color: _activePage == "chats"
                ? CustomColors.white
                : CustomColors.black,
            onTap: () {
              context.go(Chats.path);
            },
          ),
        ],
      ),
    );
  }
}
