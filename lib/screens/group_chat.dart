import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../consts/custom_colors.dart';
import '../consts/custom_typography.dart';
import '../model/chat_item.dart';
import '../model/chat_message.dart';
import '../model/user_profile.dart';
import '../providers/chat_list.dart';
import '../providers/messages.dart';
import '../providers/user_profiles.dart';
import '../widget/chat/custom_message.dart';
import '../widget/chat/select_dates_dialog.dart';
import '../widget/custom_app_bar.dart';

class GroupChat extends ConsumerStatefulWidget {
  static String path = "/group";
  final String chatId;
  final ChatItemState chatState;

  const GroupChat({super.key, required this.chatId, required this.chatState});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GroupChatState();
}

class _GroupChatState extends ConsumerState<GroupChat> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  final ScrollController _scrollController = ScrollController();

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
        return const SelectDatesDialog();
      },
    );

    if (selectedDates != null) {
      final ChatItem currentChat = await ref.read(
        getChatItemByIdProvider(widget.chatId).future,
      );

      final ChatItem toUpdate = currentChat.copyWith(
        state: ChatItemState.ongoing.name,
      );
      await ref
          .read(chatListProvider.notifier)
          .updateChat(chatId: widget.chatId, updatedChat: toUpdate);

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

  @override
  Widget build(BuildContext context) {
    final AsyncValue<PaginatedChatMessage> messageAsync = ref.watch(
      messagesProvider(widget.chatId),
    );

    final AsyncValue<UserProfile> userAsync = ref.watch(userProfilesProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Group Chat'),
      body: Column(
        children: <Widget>[
          Expanded(
            child: userAsync.when(
              data: (UserProfile user) {
                return messageAsync.when(
                  data: (PaginatedChatMessage data) {
                    final List<ChatMessage> displayMessages = data.chatMessages;
                    return Container(
                      color: CustomColors.white.withValues(alpha: 0.5),
                      child: CustomScrollView(
                        controller: _scrollController,
                        reverse: true,
                        slivers: <Widget>[
                          SliverPadding(
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
                                final AsyncValue<UserProfile> messageUser = ref
                                    .watch(getUserByIdProvider(message.userId));

                                return messageUser.when(
                                  data: (UserProfile data) {
                                    final bool isUserMessage =
                                        message.userId == user.userId;
                                    return CustomMessage(
                                      isUserMessage: isUserMessage,
                                      userId: user.userId,
                                      message: message,
                                      dateUpdateCount: message.content.when(
                                        text: (String text) => null,
                                        date:
                                            (
                                              DateTime date,
                                              List<String> likes,
                                            ) => likes.length,
                                        film:
                                            (
                                              String film,
                                              List<String> likes,
                                              List<String> dislikes,
                                              String? comment,
                                            ) => null,
                                      ),
                                      dateLikeFunction: () async {
                                        await ref
                                            .read(
                                              messagesProvider(
                                                widget.chatId,
                                              ).notifier,
                                            )
                                            .addMessageDate(
                                              userId: user.userId,
                                              chatId: widget.chatId,
                                              messageId: message.id,
                                            );
                                      },
                                      removeDateLikeFunction: () async {
                                        await ref
                                            .read(
                                              messagesProvider(
                                                widget.chatId,
                                              ).notifier,
                                            )
                                            .removeMessageDate(
                                              userId: user.userId,
                                              chatId: widget.chatId,
                                              messageId: message.id,
                                            );
                                      },
                                      senderName:
                                          user.userId == data.firstLastName
                                          ? user.firstLastName
                                          : data.firstLastName,
                                    );
                                  },
                                  error: (_, __) => const Text("Error"),
                                  loading: () => const Center(
                                    child: CircularProgressIndicator(),
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
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Scrivi un messaggio",
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
