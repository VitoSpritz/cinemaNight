import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../widget/create_chat_dialog.dart';
import '../widget/custom_add_button.dart';
import '../widget/custom_app_bar.dart';
import '../widget/custom_icon_button.dart';
import '../widget/search_modal.dart';
import 'chat_list.dart';

class Chats extends ConsumerStatefulWidget {
  static String path = '/chats';

  const Chats({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatsState();
}

class _ChatsState extends ConsumerState<Chats> {
  String? _chatName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)!.chats,
        actionButton: CustomIconButton(
          icon: Icons.search,
          onTap: () async {
            final String? searchValue = await SearchModal.show(
              title: AppLocalizations.of(context)!.searchAChat,
              context: context,
            );
            setState(() {
              _chatName = searchValue;
            });
          },
        ),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: <double>[0, 0.19, 0.41, 1.0],
                colors: <Color>[
                  Color(0xFF5264DE),
                  Color(0xFF212C77),
                  Color(0xFF050031),
                  Color(0xFF050031),
                ],
              ),
            ),
          ),
          ChatList(chatName: _chatName),
        ],
      ),
      floatingActionButton: CustomAddButton(
        onPressed: () {
          CreateChatDialog.show(context: context);
        },
      ),
    );
  }
}
