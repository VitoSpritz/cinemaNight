import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../consts/custom_colors.dart';
import '../consts/custom_typography.dart';
import '../helpers/app_palette.dart';
import '../l10n/app_localizations.dart';
import '../model/chat_item.dart';
import '../model/chat_message.dart';
import '../model/user_profile.dart';
import '../providers/chat_list.dart';
import '../providers/get_film_message.dart';
import '../providers/get_user_by_chat_id.dart';
import '../providers/messages.dart';
import '../providers/user_profiles.dart';
import '../widget/chat/chat_recap.dart';
import '../widget/chat/custom_message.dart';
import '../widget/chat/select_dates_dialog.dart';
import '../widget/custom_app_bar.dart';
import '../widget/film_suggestion_modal.dart';
import '../widget/user_list_modal.dart';

class GroupChat extends ConsumerStatefulWidget {
  static String path = "/group";
  final String chatId;
  final DateTime maxDate;

  const GroupChat({super.key, required this.chatId, required this.maxDate});

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
      final ChatItem chat = await ref.read(
        getChatItemByIdProvider(widget.chatId).future,
      );

      final UserProfile user = await ref.read(userProfilesProvider.future);

      final ChatItemState? currentState = chat.state.toChatItemState();
      final bool isChatCreator = chat.createdBy == user.userId;

      if (currentState == ChatItemState.opened && isChatCreator) {
        await _showInitialStateDialog(context);
      }

      if (currentState == ChatItemState.closed) {
        await showCustomBottomModal();
      }
    });
  }

  Future<void> showCustomBottomModal() async {
    await showModalBottomSheet(
      context: context,
      elevation: 0.0,
      useSafeArea: true,
      isScrollControlled: true,
      isDismissible: true,
      builder: (BuildContext context) {
        return ChatRecap(chatId: widget.chatId);
      },
    );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              )!.groupChatSnackBarError(e.toString()),
            ),
          ),
        );
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
      final ChatItem currentChat = await ref.read(
        getChatItemByIdProvider(widget.chatId).future,
      );

      final ChatItem toUpdate = currentChat.copyWith(
        state: ChatItemState.dateSelection.name,
        endDateSelection: DateTime.now().add(const Duration(hours: 48)),
      );
      await ref
          .read(chatListProvider.notifier)
          .updateChat(chatId: widget.chatId, updatedChat: toUpdate);

      ref.invalidate(getChatItemByIdProvider(widget.chatId));
      ref.invalidate(userChatListProvider(user.value!.userId));

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              )!.groupChatSnackBarError(e.toString()),
            ),
          ),
        );
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

    final ChatItem actualChat = await ref.read(
      getChatItemByIdProvider(chatId).future,
    );

    if (mounted) {
      await UserListModal.show(
        title: AppLocalizations.of(context)!.groupChatUserModalTitle,
        userList: userList,
        context: context,
        chat: actualChat,
      );
    }
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

    final ChatItemState? currentChatState = chatAsync.value?.state
        .toChatItemState();

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

    final String chatName = chatAsync.value != null
        ? chatAsync.value!.name
        : AppLocalizations.of(context)!.groupChatMainTitle;

    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            gradient: AppPalette.of(context).backgroudColor.defaultColor,
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: CustomAppBar(
            title: chatName,
            rightIcon: Icons.info,
            hideMainIcon: true,
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
                            final List<ChatMessage> displayMessages = data
                                .chatMessages
                                .toList();
                            return CustomScrollView(
                              controller: _scrollController,
                              reverse: true,
                              slivers: <Widget>[
                                displayMessages.isEmpty
                                    ? SliverToBoxAdapter(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Center(
                                              child: Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.groupChatNoMessageAvailable,
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
                                              (
                                                BuildContext context,
                                                int index,
                                              ) {
                                                return const SizedBox(
                                                  height: 8,
                                                );
                                              },
                                          itemBuilder: (BuildContext context, int index) {
                                            final ChatMessage message =
                                                displayMessages[index];
                                            final AsyncValue<UserProfile>
                                            messageUser = ref.watch(
                                              getUserByIdProvider(
                                                message.userId,
                                              ),
                                            );

                                            return messageUser.when(
                                              data: (UserProfile data) {
                                                final bool isUserMessage =
                                                    message.userId ==
                                                    user.userId;
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
                            );
                          },
                          error: (_, __) {
                            return const Center(child: Text("Error "));
                          },
                          loading: () {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
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
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
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
                              ? AppLocalizations.of(context)!.chatTextHint
                              : AppLocalizations.of(
                                  context,
                                )!.chatBarDisabledHintText,
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
                      onTap:
                          (canAddFilm &&
                              currentChatState == ChatItemState.filmSelection)
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
                          color:
                              canAddFilm &&
                                  currentChatState ==
                                      ChatItemState.filmSelection
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
        ),
      ],
    );
  }
}
