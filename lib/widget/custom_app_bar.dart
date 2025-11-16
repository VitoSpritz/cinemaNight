import 'package:flutter/material.dart';

import '../consts/custom_colors.dart';
import '../consts/custom_typography.dart';
import 'custom_icon_button.dart';
import 'search_modal.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool searchEnabled;
  final Function(String?)? onSearch;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.searchEnabled,
    this.onSearch,
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
            if (searchEnabled == true)
              CustomIconButton(
                icon: Icons.search,
                onTap: () async {
                  final String? searchValue = await SearchModal.show(
                    context: context,
                  );
                  if (onSearch != null) {
                    onSearch!(searchValue);
                  }
                },
                color: CustomColors.text,
              )
            else
              const SizedBox(width: 60),
          ],
        ),
      ),
    );
  }
}
