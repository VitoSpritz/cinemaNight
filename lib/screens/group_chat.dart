import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../consts/custom_colors.dart';
import '../consts/custom_typography.dart';
import '../model/chat_item.dart';
import '../model/chat_message.dart';
import '../model/user_profile.dart';
import '../providers/chat_list.dart';
import '../providers/get_film_message.dart';
import '../providers/get_user_by_chat_id.dart';
import '../providers/messages.dart';
import '../providers/user_profiles.dart';
import '../widget/chat/custom_message.dart';
import '../widget/chat/select_dates_dialog.dart';
import '../widget/chat/select_end_date.dart';
import '../widget/custom_app_bar.dart';
import '../widget/film_suggestion_modal.dart';
import '../widget/user_list_modal.dart';
import 'chats.dart';

class GroupChat extends ConsumerStatefulWidget {
  static String path = "/group";
  final String chatId;
  final ChatItemState chatState;
  final DateTime maxDate;

  const GroupChat({
    super.key,
    required this.chatId,
    required this.chatState,
    required this.maxDate,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GroupChatState();
}

class _GroupChatState extends ConsumerState<GroupChat> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  final ScrollController _scrollController = ScrollController();
  String? _suggestedFilmName;

  @override
  void dispose() {
    _messageController.dispose();
    _chatScrollController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.chatState == ChatItemState.opened) {
        await _showInitialStateDialog(context);
      }
    });
  }

  Future<void> _sendMessage({required String userId}) async {
    final String message = _messageController.text.trim();

    if (message.isEmpty) {
      return;
    }

    try {
      await ref
          .read(messagesProvider(widget.chatId).notifier)
          .createMessage(
            chatId: widget.chatId,
            sentAt: DateTime.now(),
            sentBy: userId,
            content: ChatContent.text(text: _messageController.text),
          );
      _messageController.clear();

      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Errore nell\'invio: $e')));
      }
    }
  }

  Future<void> _showInitialStateDialog(BuildContext context) async {
    final AsyncValue<UserProfile> user = ref.read(userProfilesProvider);
    if (user.value == null) {
      throw Error();
    }

    final List<DateTime?>? selectedDates = await showDialog<List<DateTime?>>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return SelectDatesDialog(maxDate: widget.maxDate);
      },
    );

    if (selectedDates != null) {
      final DateTime? endDate = await showDialog<DateTime>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const SelectEndDate();
        },
      );
      if (endDate != null) {
        final ChatItem currentChat = await ref.read(
          getChatItemByIdProvider(widget.chatId).future,
        );

        final ChatItem toUpdate = currentChat.copyWith(
          state: ChatItemState.dateSelection.name,
          endDateSelection: endDate,
        );
        await ref
            .read(chatListProvider.notifier)
            .updateChat(chatId: widget.chatId, updatedChat: toUpdate);

        ref.invalidate(getChatItemByIdProvider(widget.chatId));

        for (DateTime? date in selectedDates) {
          final ChatContent content = ChatContent.date(proposedDate: date!);
          await ref
              .read(messagesProvider(widget.chatId).notifier)
              .createMessage(
                chatId: widget.chatId,
                sentBy: user.value!.userId,
                sentAt: DateTime.now(),
                content: content,
              );
        }
      } else {
        context.go(Chats.path);
      }
    }
  }

  Future<void> _sendSugggestedFilm({
    required String userId,
    required String filmName,
  }) async {
    try {
      await ref
          .read(messagesProvider(widget.chatId).notifier)
          .createMessage(
            chatId: widget.chatId,
            sentAt: DateTime.now(),
            sentBy: userId,
            content: ChatContent.film(filmId: filmName),
          );

      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Errore nell\'invio: $e')));
      }
    }
  }

  Future<String?> _showModal() async {
    return await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return const FilmSuggestionModal();
      },
    );
  }

  Future<void> _showUserListModal({required String chatId}) async {
    final List<UserProfile> userList = await ref.read(
      getUsersByChatProvider(chatId: chatId).future,
    );

    await UserListModal.show(
      title: "Utenti iscritti",
      userList: userList,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<PaginatedChatMessage> messageAsync = ref.watch(
      messagesProvider(widget.chatId),
    );

    final AsyncValue<UserProfile> userAsync = ref.watch(userProfilesProvider);

    final AsyncValue<ChatItem> chatAsync = ref.watch(
      getChatItemByIdProvider(widget.chatId),
    );

    final bool isChatCreator =
        chatAsync.whenOrNull(
          data: (ChatItem chat) => userAsync.whenOrNull(
            data: (UserProfile user) => chat.createdBy == user.userId,
          ),
        ) ??
        false;

    final bool canAddFilm =
        userAsync.whenOrNull(
          data: (UserProfile user) {
            final AsyncValue<ChatMessage?> filmMessageAsync = ref.watch(
              getFilmMessageProvider(user.userId, widget.chatId),
            );
            return filmMessageAsync.whenOrNull(
                  data: (ChatMessage? msg) => msg == null,
                ) ??
                true;
          },
        ) ??
        true;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Group Chat',
        rightIcon: Icons.info,
        onRightIconTap: () => _showUserListModal(chatId: widget.chatId),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: userAsync.when(
              data: (UserProfile user) {
                return chatAsync.when(
                  data: (ChatItem chat) {
                    return messageAsync.when(
                      data: (PaginatedChatMessage data) {
                        final List<ChatMessage> displayMessages =
                            data.chatMessages;
                        return Container(
                          color: CustomColors.white.withValues(alpha: 0.5),
                          child: CustomScrollView(
                            controller: _scrollController,
                            reverse: true,
                            slivers: <Widget>[
                              displayMessages.isEmpty
                                  ? const SliverToBoxAdapter(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Center(
                                            child: Text(
                                              "Non ci sono ancora messaggi",
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : SliverPadding(
                                      padding: const EdgeInsets.all(16),
                                      sliver: SliverList.separated(
                                        itemCount: displayMessages.length,
                                        separatorBuilder:
                                            (BuildContext context, int index) {
                                              return const SizedBox(height: 8);
                                            },
                                        itemBuilder: (BuildContext context, int index) {
                                          final ChatMessage message =
                                              displayMessages[index];
                                          final AsyncValue<UserProfile>
                                          messageUser = ref.watch(
                                            getUserByIdProvider(message.userId),
                                          );

                                          return messageUser.when(
                                            data: (UserProfile data) {
                                              final bool isUserMessage =
                                                  message.userId == user.userId;
                                              return CustomMessage(
                                                isUserMessage: isUserMessage,
                                                userId: user.userId,
                                                message: message,
                                                chatState: chat.state
                                                    .toChatItemState()!,
                                                onLikeFunction: () async {
                                                  await ref
                                                      .read(
                                                        messagesProvider(
                                                          widget.chatId,
                                                        ).notifier,
                                                      )
                                                      .addLikeToMessage(
                                                        userId: user.userId,
                                                        chatId: widget.chatId,
                                                        messageId: message.id,
                                                      );
                                                },
                                                onRemoveLikeFunction: () async {
                                                  await ref
                                                      .read(
                                                        messagesProvider(
                                                          widget.chatId,
                                                        ).notifier,
                                                      )
                                                      .removeLikeFromMessage(
                                                        userId: user.userId,
                                                        chatId: widget.chatId,
                                                        messageId: message.id,
                                                      );
                                                },
                                                onDislikeFunction: () async {
                                                  await ref
                                                      .read(
                                                        messagesProvider(
                                                          widget.chatId,
                                                        ).notifier,
                                                      )
                                                      .addDislikeToMessage(
                                                        userId: user.userId,
                                                        chatId: widget.chatId,
                                                        messageId: message.id,
                                                      );
                                                },
                                                onRemoveDilikeFunction: () async {
                                                  await ref
                                                      .read(
                                                        messagesProvider(
                                                          widget.chatId,
                                                        ).notifier,
                                                      )
                                                      .removeDislikeFromMessage(
                                                        userId: user.userId,
                                                        chatId: widget.chatId,
                                                        messageId: message.id,
                                                      );
                                                },
                                                senderName:
                                                    user.userId ==
                                                        data.firstLastName
                                                    ? user.firstLastName
                                                    : data.firstLastName,
                                              );
                                            },
                                            error: (_, __) =>
                                                const Text("Error"),
                                            loading: () => const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                            ],
                          ),
                        );
                      },
                      error: (_, __) {
                        return const Center(child: Text("Error "));
                      },
                      loading: () {
                        return const Center(child: CircularProgressIndicator());
                      },
                    );
                  },
                  error: (_, __) {
                    return const Center(child: Text("Chat error"));
                  },
                  loading: () {
                    return const Center(child: CircularProgressIndicator());
                  },
                );
              },
              error: (_, __) {
                return const Center(child: Text("User error"));
              },
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(
              top: 16,
              left: 8,
              right: 8,
              bottom: MediaQuery.of(context).padding.bottom + 12.0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  child: TextField(
                    enabled: isChatCreator,
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: isChatCreator
                          ? "Scrivi un messaggio"
                          : "Non sei l'amministratore del gruppo",
                      hintStyle: CustomTypography.caption,
                      filled: true,
                      fillColor: CustomColors.white.withValues(alpha: 0.4),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: CustomColors.black.withValues(alpha: 0.2),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: CustomColors.black.withValues(alpha: 0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                          color: CustomColors.lightBlue,
                          width: 2,
                        ),
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    minLines: 1,
                    maxLines: 4,
                    onSubmitted: (_) async =>
                        await _sendMessage(userId: userAsync.value!.userId),
                    onTapOutside: (PointerDownEvent event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: canAddFilm
                      ? () async {
                          _suggestedFilmName = await _showModal();
                          if (_suggestedFilmName != null) {
                            await _sendSugggestedFilm(
                              userId: userAsync.value!.userId,
                              filmName: _suggestedFilmName!,
                            );
                            ref.invalidate(
                              getFilmMessageProvider(
                                userAsync.value!.userId,
                                widget.chatId,
                              ),
                            );
                          }
                        }
                      : null,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: canAddFilm
                          ? CustomColors.purple
                          : CustomColors.purple.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: CustomColors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (isChatCreator)
                  GestureDetector(
                    onTap: () async =>
                        await _sendMessage(userId: userAsync.value!.userId),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: CustomColors.black,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: CustomColors.white,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
