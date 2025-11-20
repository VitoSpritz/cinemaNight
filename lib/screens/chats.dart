import 'package:flutter/material.dart';

import '../consts/custom_colors.dart';
import '../l10n/app_localizations.dart';
import '../widget/create_chat_dialog.dart';
import '../widget/custom_add_button.dart';
import '../widget/custom_app_bar.dart';
import '../widget/custom_icon_button.dart';
import 'chat_list.dart';

class Chats extends StatelessWidget {
  static String path = '/chats';

  const Chats({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)!.chats,
        actionButton: CustomIconButton(
          icon: Icons.search,
          onTap: () {},
          iconSize: 45,
          color: CustomColors.text,
        ),
      ),
      body: const ChatList(),
      floatingActionButton: CustomAddButton(
        onPressed: () {
          CreateChatDialog.show(context: context);
        },
      ),
    );
  }
}
