import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../consts/custom_colors.dart';
import '../consts/custom_typography.dart';
import '../l10n/app_localizations.dart';
import '../model/chat_item.dart';
import '../model/user_profile.dart';
import '../providers/chat_list.dart';
import '../providers/user_profiles.dart';
import '../services/chat_service.dart';
import '../widget/chat/chat_list_item.dart';
import '../widget/custom_icon_button.dart';

class ChatList extends ConsumerStatefulWidget {
  final String? chatName;

  const ChatList({super.key, this.chatName});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatListState();
}

class _ChatListState extends ConsumerState<ChatList> {
  final ScrollController _scrollController = ScrollController();
  String? _activeSearchQuery;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _activeSearchQuery = widget.chatName;
  }

  @override
  void didUpdateWidget(ChatList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.chatName != oldWidget.chatName && widget.chatName != null) {
      setState(() {
        _activeSearchQuery = widget.chatName;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      if (_activeSearchQuery == null || _activeSearchQuery!.isEmpty) {
        final PaginatedChatItem? chatState = ref.read(chatListProvider).value;
        if (chatState != null && chatState.hasMore) {
          ref.read(chatListProvider.notifier).loadMoreChats();
        }
      }
    }
  }

  Widget _buildChatList(PaginatedChatItem data, UserProfile user) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(chatListProvider);
        await ref.read(chatListProvider.future);
      },
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.all(8.0),
            sliver: SliverList.separated(
              itemCount: data.chatItems.length + (data.hasMore ? 1 : 0),
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(height: 1),
              itemBuilder: (BuildContext context, int index) {
                if (index == data.chatItems.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final ChatItem chat = data.chatItems[index];

                return ChatListItem(
                  chat: chat,
                  user: user,
                  deleteFunction: () async =>
                      await _deleteChat(userId: user.userId, chatId: chat.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteChat({
    required String userId,
    required String chatId,
  }) async {
    try {
      final ChatService service = ChatService();
      await service.deleteChat(userId: userId, chatId: chatId);

      ref.invalidate(chatListProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chat eliminata con successo')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore nell\'eliminazione: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<PaginatedChatItem> paginatedChat = ref.watch(
      chatListProvider,
    );
    final AsyncValue<UserProfile> loggedUser = ref.watch(userProfilesProvider);

    final String? searchQuery = _activeSearchQuery;

    return Column(
      children: <Widget>[
        if (searchQuery != null && searchQuery.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  border: Border.all(color: CustomColors.black, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 6.0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(
                        Icons.search,
                        size: 16,
                        color: CustomColors.lightBlue,
                      ),
                      const SizedBox(width: 4),
                      Text(searchQuery, style: CustomTypography.caption),
                      const SizedBox(width: 4),
                      CustomIconButton(
                        icon: Icons.close,
                        color: CustomColors.black,
                        iconSize: 14,
                        padding: 4,
                        onTap: () => setState(() {
                          _activeSearchQuery = null;
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        Expanded(
          child: loggedUser.when(
            data: (UserProfile user) {
              return paginatedChat.when(
                data: (PaginatedChatItem data) {
                  if (searchQuery != null && searchQuery.isNotEmpty) {
                    final AsyncValue<List<ChatItem>> searchResult = ref.watch(
                      chatByNameProvider(searchQuery),
                    );

                    return searchResult.when(
                      data: (List<ChatItem> foundChats) {
                        if (foundChats.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                const Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Nessuna chat trovata per "$searchQuery"',
                                  style: CustomTypography.body,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => setState(() {
                                    _activeSearchQuery = null;
                                  }),
                                  child: const Text('Cancella ricerca'),
                                ),
                              ],
                            ),
                          );
                        }

                        return _buildChatList(
                          PaginatedChatItem(
                            chatItems: foundChats,
                            hasMore: false,
                            startAfter: null,
                          ),
                          user,
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (Object error, StackTrace stack) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text('Errore nella ricerca: $error'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => setState(() {
                                _activeSearchQuery = null;
                              }),
                              child: const Text('Cancella ricerca'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (data.chatItems.isEmpty) {
                    return Center(
                      child: Text(
                        AppLocalizations.of(context)!.noChatAvailable,
                      ),
                    );
                  }

                  return _buildChatList(data, user);
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
            error: (_, __) => const Center(child: Text("Error loading user")),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
    );
  }
}
