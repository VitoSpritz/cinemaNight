import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../consts/custom_colors.dart';

class CustomBottomBar extends ConsumerWidget {
  final String? activePage;
  const CustomBottomBar({
    Key? key,
    required this.navigationShell,
    this.activePage,
  }) : super(key: key ?? const ValueKey('CustomBottomBar'));

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        height: 66,
        color: CustomColors.mainYellow,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(
              index: 0,
              icon: Icons.account_box_rounded,
              label: "Account",
            ),
            _buildNavItem(index: 1, icon: Icons.list, label: "Library"),
            _buildNavItem(index: 2, icon: Icons.chat, label: "Chats"),
            _buildNavItem(index: 3, icon: Icons.home, label: "Home"),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool isActive = navigationShell.currentIndex == index;

    return GestureDetector(
      onTap: () => _goBranch(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            icon,
            color: isActive ? CustomColors.white : CustomColors.black,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? CustomColors.white : CustomColors.black,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
