import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../helpers/app_palette.dart';
import '../l10n/app_localizations.dart';
import '../widget/create_chat_dialog.dart';
import '../widget/custom_add_button.dart';
import '../widget/custom_app_bar.dart';
import '../widget/custom_search_bar.dart';
import 'chat_list.dart';

class Chats extends ConsumerStatefulWidget {
  static String path = '/chats';

  const Chats({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatsState();
}

class _ChatsState extends ConsumerState<Chats> {
  String? _chatName;
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppLocalizations.of(context)!.chats),
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: AppPalette.of(context).backgroudColor.defaultColor,
            ),
          ),
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 8.0,
                ),
                child: CustomSearchBar(
                  searchController: searchController,
                  onSubmitFunction: () => setState(() {
                    _chatName = searchController.text;
                  }),
                ),
              ),
              Expanded(child: ChatList(chatName: _chatName)),
            ],
          ),
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
