import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../consts/custom_colors.dart';
import '../consts/custom_typography.dart';
import '../model/chat_item.dart';
import '../providers/chat_list.dart';
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
    _currentState = widget.chatState;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.chatState == ChatItemState.opened.name) {
        await _showInitialStateDialog(context);
      }
    });
  }

  Future<void> _sendMessage() async {
    final String message = _messageController.text.trim();

    if (message.isEmpty) {
      return;
    }

    try {
      // TODO: Send message

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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Group Chat'),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              color: CustomColors.white.withValues(alpha: 0.5),
              child: ListView.builder(
                controller: _chatScrollController,
                padding: const EdgeInsets.all(16),
                itemCount: 0,
                itemBuilder: (BuildContext context, int index) {
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),

          Container(
            decoration: BoxDecoration(
              color: CustomColors.white,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  top: 16,
                  left: 8,
                  right: 8,
                  bottom: MediaQuery.of(context).padding.bottom + 4.0,
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
                        onSubmitted: (_) => _sendMessage(),
                        onTapOutside: (PointerDownEvent event) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),

                    GestureDetector(
                      onTap: _sendMessage,
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
            ),
          ),
        ],
      ),
    );
  }
}
