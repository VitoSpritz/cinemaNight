import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/chat_item.dart';
import '../services/chat_service.dart';

part 'chat_list.g.dart';

@Riverpod(keepAlive: true)
class ChatList extends _$ChatList {
  final ChatService service = ChatService();
  bool _isFetchingMore = false;

  @override
  Future<PaginatedChatItem> build() async {
    return await service.getFirstChatPage();
  }

  Future<void> createChat({
    required String createdBy,
    required DateTime closesAt,
    required String name,
    required String password,
    required String? description,
  }) async {
    await service.createChat(
      createdBy: createdBy,
      closesAt: closesAt,
      name: name,
      password: password,
      description: description,
    );
    ref.invalidateSelf();
  }

  Future<void> updateChat({
    required String chatId,
    required ChatItem updatedChat,
  }) async {
    service.updateChat(chatId: chatId, updatedChat: updatedChat);

    ref.invalidateSelf();
  }

  Future<void> loadMoreChats() async {
    if (_isFetchingMore) {
      return;
    }

    final PaginatedChatItem? currentData = state.value;

    if (currentData == null || !currentData.hasMore) {
      return;
    }

    if (currentData.startAfter == null) {
      return;
    }

    _isFetchingMore = true;

    try {
      final PaginatedChatItem nextPage = await service.getMoreChat(
        lastDocument: currentData.startAfter!,
      );

      final List<ChatItem> updatedChatItems = <ChatItem>[
        ...currentData.chatItems,
        ...nextPage.chatItems,
      ];

      // ignore: always_specify_types
      state = AsyncValue.data(
        PaginatedChatItem(
          chatItems: updatedChatItems,
          hasMore: nextPage.hasMore,
          startAfter: nextPage.startAfter,
        ),
      );
    } catch (e, st) {
      // ignore: always_specify_types
      state = AsyncError(e, st);
    } finally {
      _isFetchingMore = false;
    }
  }
}

@riverpod
Future<List<ChatItem>> chatByName(Ref ref, String chatName) async {
  final ChatService service = ChatService();
  return await service.getChatByName(chatName: chatName);
}

@riverpod
Future<ChatItem> getChatItemById(Ref ref, String chatId) async {
  final ChatService service = ChatService();
  return await service.getChatById(chatId: chatId);
}

@riverpod
Future<PaginatedChatItem> userChatList(Ref ref, String userId) async {
  final ChatService service = ChatService();
  return await service.getChatsByUser(userId: userId);
}
