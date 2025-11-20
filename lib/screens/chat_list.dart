import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../model/chat_item.dart';
import '../model/user_profile.dart';
import '../providers/chat_list.dart';
import '../providers/user_profiles.dart';
import '../services/chat_service.dart';
import '../widget/confirm_dialog.dart';

class ChatList extends ConsumerStatefulWidget {
  const ChatList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatListState();
}

class _ChatListState extends ConsumerState<ChatList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      final PaginatedChatItem? chatState = ref.read(chatListProvider).value;
      if (chatState != null && chatState.hasMore) {
        ref
            .read(chatListProvider.notifier)
            .listMoreChat(lastDocument: chatState.startAfter!);
      }
    }
  }

  void _deleteChat({required String userId, required String chatId}) async {
    final ChatService service = ChatService();
    await service.deleteChat(userId: userId, chatId: chatId);
    ref.invalidate(chatListProvider);
  }

  String _getStateText(String state) {
    switch (state) {
      case "opened":
        return 'Aperto';
      case "ongoing":
        return 'In corso';
      case "closed":
        return 'Chiuso';
    }
    return "Erorr";
  }

  Color _getStateColor(String state) {
    switch (state) {
      case "opened":
        return Colors.green;
      case "ongoing":
        return Colors.orange;
      case "closed":
        return Colors.grey;
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<PaginatedChatItem> paginatedChat = ref.watch(
      chatListProvider,
    );
    final AsyncValue<UserProfile> loggedUser = ref.watch(userProfilesProvider);

    return Column(
      children: <Widget>[
        Expanded(
          child: loggedUser.when(
            data: (UserProfile user) {
              return paginatedChat.when(
                data: (PaginatedChatItem data) {
                  if (data.chatItems.isEmpty) {
                    return const Center(
                      child: Text("Nessuna chat disponibile"),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(chatListProvider);
                    },
                    child: CustomScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: <Widget>[
                        SliverPadding(
                          padding: const EdgeInsets.all(8.0),
                          sliver: SliverList.separated(
                            itemCount:
                                data.chatItems.length + (data.hasMore ? 1 : 0),
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const Divider(height: 1),
                            itemBuilder: (BuildContext context, int index) {
                              if (index == data.chatItems.length) {
                                return const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              final ChatItem chat = data.chatItems[index];

                              return ListTile(
                                onLongPress: () {
                                  ConfirmDialog.show(
                                    context: context,
                                    title: "Attenzione!",
                                    subtitle:
                                        "Sei dicuro di voler eliminare questa chat ${chat.name}?",
                                    cancelFunction: () async => context.pop(),
                                    confirmFunction: () async => _deleteChat(
                                      chatId: chat.id,
                                      userId: user.userId,
                                    ),
                                  );
                                },
                                onTap: () {},
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                title: Text(
                                  user.savedChats != null &&
                                          user.savedChats?.contains(chat.id) ==
                                              true
                                      ? '${chat.name} Salvata!'
                                      : chat.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    DateFormat(
                                      'dd/MM/yyyy HH:mm',
                                    ).format(chat.createdAt),
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStateColor(
                                      chat.state ?? "closed",
                                    ).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _getStateText(chat.state ?? "closed"),
                                    style: TextStyle(
                                      color: _getStateColor(
                                        chat.state ?? "closed",
                                      ),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
                error: (Object error, StackTrace stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text("Errore: $error"),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref.invalidate(chatListProvider);
                          },
                          child: const Text("Riprova"),
                        ),
                      ],
                    ),
                  );
                },
                loading: () {
                  return const Center(child: CircularProgressIndicator());
                },
              );
            },
            error: (_, __) => const Center(child: Text("Error")),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
    );
  }
}
