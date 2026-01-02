import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../consts/custom_colors.dart';
import '../consts/custom_typography.dart';
import '../helpers/app_palette.dart';
import '../l10n/app_localizations.dart';
import '../model/chat_item.dart';
import '../model/user_profile.dart';

class UserListModal extends ConsumerWidget {
  final String title;
  final List<UserProfile> userList;
  final ChatItem chat;

  const UserListModal({
    super.key,
    required this.title,
    required this.userList,
    required this.chat,
  });

  static Future<String?> show({
    required BuildContext context,
    required String title,
    required List<UserProfile> userList,
    required ChatItem chat,
    Future<void> Function()? function,
  }) {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return UserListModal(title: title, userList: userList, chat: chat);
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
          spacing: 12.0,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  chat.name,
                  style: CustomTypography.titleXL.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppPalette.of(context).textColors.simpleText,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  child: Text(
                    chat.description ??
                        AppLocalizations.of(
                          context,
                        )!.userListModalNoDescriptionAvailable,
                    textAlign: TextAlign.center,
                    style: CustomTypography.titleM.copyWith(
                      color: AppPalette.of(context).textColors.simpleText,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: CustomTypography.titleXL.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppPalette.of(context).textColors.simpleText,
                    ),
                  ),
                ),
              ],
            ),
            if (userList.isEmpty)
              Text(
                AppLocalizations.of(context)!.userListModalNoUserSubscribed,
                style: CustomTypography.bodySmall.copyWith(
                  color: AppPalette.of(context).textColors.simpleText,
                ),
              )
            else
              ...userList.map(
                (UserProfile user) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        user.firstLastName ?? '',
                        style: CustomTypography.bodySmall.copyWith(
                          color: AppPalette.of(context).textColors.simpleText,
                        ),
                      ),
                      if (user.userId == chat.createdBy) const Text(" 👑"),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
