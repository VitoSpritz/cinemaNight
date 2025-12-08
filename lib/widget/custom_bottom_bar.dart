import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../consts/custom_colors.dart';
import '../consts/custom_typography.dart';
import '../consts/sizes.dart';
import '../l10n/app_localizations.dart';

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
        color: CustomColors.mainYellow,
        child: SafeArea(
          child: SizedBox(
            height: 56.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildNavItem(
                  index: 3,
                  icon: Icons.home,
                  label: AppLocalizations.of(context)!.home,
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.list,
                  label: AppLocalizations.of(context)!.reviews,
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.chat,
                  label: AppLocalizations.of(context)!.chats,
                ),
                _buildNavItem(
                  index: 0,
                  icon: Icons.account_box_rounded,
                  label: AppLocalizations.of(context)!.account,
                ),
              ],
            ),
          ),
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
      behavior: HitTestBehavior.translucent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            icon,
            color: isActive ? CustomColors.white : CustomColors.black,
            size: Sizes.iconMedium,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: CustomTypography.captionBolder.copyWith(
              color: isActive ? CustomColors.white : CustomColors.black,
            ),
          ),
        ],
      ),
    );
  }
}
