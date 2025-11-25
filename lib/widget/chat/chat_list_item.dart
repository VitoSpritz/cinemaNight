import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../consts/custom_typography.dart';
import '../../l10n/app_localizations.dart';
import '../../model/chat_item.dart';
import '../../model/user_profile.dart';
import '../../screens/group_chat.dart';
import '../confirm_dialog.dart';
import '../state_badge.dart';
import 'insert_password_dialog.dart';

class ChatListItem extends ConsumerWidget {
  final ChatItem chat;
  final UserProfile user;
  final Function()? deleteFunction;

  const ChatListItem({
    super.key,
    required this.chat,
    this.deleteFunction,
    required this.user,
  });

  Future<void> _checkUserCreation({
    required UserProfile user,
    required ChatItem chat,
    required BuildContext context,
  }) async {
    if (chat.createdBy == user.userId) {
      context.pushNamed(
        'groupChat',
        queryParameters: <String, String>{'chatId': chat.id},
      );
    } else {
      final String? password = await InsertPasswordDialog.show(
        context: context,
        mainTitle: "Accesso riservato",
        subtitle: "Inserire la password per entrare",
      );

      if (password == null) {
        return;
      }

      if (password.isNotEmpty && chat.password == password) {
        context.go(GroupChat.path);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password errata. Riprova.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      onLongPress: () {
        ConfirmDialog.show(
          context: context,
          title: "Attenzione!",
          subtitle: "Sei dicuro di voler eliminare questa chat ${chat.name}?",
          cancelFunction: () async => context.pop(),
          confirmFunction: () async {
            deleteFunction?.call();
          },
        );
      },
      onTap: () {
        _checkUserCreation(chat: chat, context: context, user: user);
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            chat.name,
            style:
                user.savedChats != null &&
                    user.savedChats?.contains(chat.id) == true
                ? CustomTypography.bodyBold
                : CustomTypography.body,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Text(
              (chat.description == null || chat.description!.isEmpty == true)
                  ? AppLocalizations.of(context)!.noDescriptionAvailable
                  : chat.description!,
              style: CustomTypography.caption,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            children: <Widget>[
              Text("Data di chiusura: ", style: CustomTypography.caption),
              Text(
                DateFormat('dd/MM/yyyy HH:mm').format(chat.closesAt),
                style: CustomTypography.caption,
              ),
            ],
          ),
        ],
      ),
      trailing: StateBadge(state: chat.state, closesAt: chat.closesAt),
    );
  }
}
