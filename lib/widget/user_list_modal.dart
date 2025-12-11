import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../consts/custom_colors.dart';
import '../consts/custom_typography.dart';
import '../l10n/app_localizations.dart';
import '../model/user_profile.dart';

class UserListModal extends ConsumerWidget {
  final String title;
  final List<UserProfile> userList;
  const UserListModal({super.key, required this.title, required this.userList});

  static Future<String?> show({
    required BuildContext context,
    required String title,
    required List<UserProfile> userList,
    Future<void> Function()? function,
  }) {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return UserListModal(title: title, userList: userList);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      alignment: Alignment.topCenter,
      scrollable: true,
      backgroundColor: CustomColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    style: CustomTypography.titleXL.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (userList.isEmpty)
              Text(
                AppLocalizations.of(context)!.userListModalNoUserSubscribed,
                style: CustomTypography.bodySmall,
              )
            else
              ...userList.map(
                (UserProfile user) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    user.firstLastName ?? '',
                    style: CustomTypography.bodySmall,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
