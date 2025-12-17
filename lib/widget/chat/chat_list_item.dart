import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../consts/custom_typography.dart';
import '../../helpers/app_palette.dart';
import '../../l10n/app_localizations.dart';
import '../../model/chat_item.dart';
import '../../model/date_model.dart';
import '../../model/user_profile.dart';
import '../../providers/chat_list.dart';
import '../../providers/user_profiles.dart';
import '../confirm_dialog.dart';
import '../state_badge.dart';
import 'insert_password_dialog.dart';

class ChatListItem extends ConsumerStatefulWidget {
  final ChatItem chat;
  final UserProfile user;
  final Function()? deleteFunction;

  const ChatListItem({
    super.key,
    required this.chat,
    this.deleteFunction,
    required this.user,
  });

  @override
  ConsumerState<ChatListItem> createState() => _ChatListItemState();
}

class _ChatListItemState extends ConsumerState<ChatListItem> {
  bool _isClosed = false;
  bool _isFilmSelection = false;

  @override
  void initState() {
    super.initState();
    _checkAndUpdateChatState();
  }

  @override
  void didUpdateWidget(covariant ChatListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chat.id != widget.chat.id) {
      _isClosed = false;
      _isFilmSelection = false;
      _checkAndUpdateChatState();
    }
  }

  Future<void> _checkUserForChat({
    required UserProfile user,
    required ChatItem chat,
    required BuildContext context,
  }) async {
    if ((chat.createdBy == user.userId) ||
        (user.savedChats?.contains(chat.id) ?? false)) {
      context.pushNamed(
        'groupChat',
        queryParameters: <String, String>{
          'chatId': chat.id,
          'chatState': chat.state,
          'maxDate': const DateTimeSerializer().toJson(chat.closesAt),
        },
      );
    } else {
      final String? password = await InsertPasswordDialog.show(
        context: context,
        mainTitle: AppLocalizations.of(context)!.chatListItemMainTitle,
        subtitle: AppLocalizations.of(context)!.chatListItemSubtitle,
      );

      if (password == null) {
        return;
      }

      if (password.isNotEmpty && chat.password == password) {
        await ref
            .read(userProfilesProvider.notifier)
            .updateUserProfile(
              userId: user.userId,
              name: user.firstLastName,
              age: user.age,
              imageUrl: user.imageUrl,
              preferredFilm: user.preferredFilm,
              preferredGenre: user.preferredGenre,
              savedChats: <String>[...?user.savedChats, chat.id],
            );
        context.pushNamed(
          'groupChat',
          queryParameters: <String, String>{
            'chatId': chat.id,
            'chatState': chat.state,
            'maxDate': const DateTimeSerializer().toJson(chat.closesAt),
          },
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.chatListItemWrongPassword,
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  void _checkAndUpdateChatState() {
    final ChatItem chat = widget.chat;

    if (chat.state == ChatItemState.closed.name) {
      return;
    }

    if (!_isClosed && chat.closesAt.isBefore(DateTime.now())) {
      _isClosed = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted) {
          await ref
              .read(chatListProvider.notifier)
              .updateChat(
                chatId: chat.id,
                updatedChat: chat.copyWith(state: ChatItemState.closed.name),
              );
        }
      });
      return;
    }

    if (!_isFilmSelection &&
        chat.state != ChatItemState.filmSelection.name &&
        chat.endDateSelection?.isBefore(DateTime.now()) == true) {
      _isFilmSelection = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted) {
          await ref
              .read(chatListProvider.notifier)
              .updateChat(
                chatId: chat.id,
                updatedChat: chat.copyWith(
                  state: ChatItemState.filmSelection.name,
                ),
              );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onLongPress: () {
        if (widget.user.userId == widget.chat.createdBy) {
          ConfirmDialog.show(
            context: context,
            title: "Attenzione!",
            subtitle: AppLocalizations.of(
              context,
            )!.chatListItemDeleteChatMessage(widget.chat.name),
            cancelFunction: () async => context.pop(),
            confirmFunction: () async {
              widget.deleteFunction?.call();
            },
          );
        }
      },
      onTap: () async {
        await _checkUserForChat(
          chat: widget.chat,
          context: context,
          user: widget.user,
        );
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.chat.name,
            style:
                widget.user.savedChats != null &&
                    widget.user.savedChats?.contains(widget.chat.id) == true
                ? CustomTypography.bodyBold.copyWith(
                    color: AppPalette.of(context).textColors.defaultColor,
                  )
                : CustomTypography.body.copyWith(
                    color: AppPalette.of(context).textColors.defaultColor,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Text(
              (widget.chat.description == null ||
                      widget.chat.description!.isEmpty == true)
                  ? AppLocalizations.of(context)!.noDescriptionAvailable
                  : widget.chat.description!,
              style: CustomTypography.caption.copyWith(
                color: AppPalette.of(context).textColors.defaultColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            children: <Widget>[
              Text(
                AppLocalizations.of(context)!.chatListItemClosesAt,
                style: CustomTypography.caption.copyWith(
                  color: AppPalette.of(context).textColors.defaultColor,
                ),
              ),
              Expanded(
                child: Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(widget.chat.closesAt),
                  overflow: TextOverflow.ellipsis,
                  style: CustomTypography.caption.copyWith(
                    color: AppPalette.of(context).textColors.defaultColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: StateBadge(
        state: widget.chat.state,
        closesAt: widget.chat.closesAt,
      ),
    );
  }
}
