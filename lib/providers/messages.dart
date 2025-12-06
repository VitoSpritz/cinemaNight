import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/chat_message.dart';
import '../services/chat_messages.dart';

part 'messages.g.dart';

@riverpod
class Messages extends _$Messages {
  final ChatMessages service = ChatMessages();
  bool _isFetchingMore = false;

  @override
  Stream<PaginatedChatMessage> build(String chatId) async* {
    await for (final List<ChatMessage> messages in service.watchMessages(
      chatId: chatId,
    )) {
      yield PaginatedChatMessage(
        chatMessages: messages,
        hasMore: messages.length >= 50,
        startAfter: null,
      );
    }
  }

  Future<void> addLikeToMessage({
    required String userId,
    required String chatId,
    required String messageId,
  }) async {
    await service.addLikeToMessage(
      userId: userId,
      chatId: chatId,
      messageId: messageId,
    );
    ref.invalidateSelf();
  }

  Future<void> removeLikeFromMessage({
    required String userId,
    required String chatId,
    required String messageId,
  }) async {
    await service.removeLikeFromMessage(
      userId: userId,
      chatId: chatId,
      messageId: messageId,
    );
    ref.invalidateSelf();
  }

  Future<void> addDislikeToMessage({
    required String userId,
    required String chatId,
    required String messageId,
  }) async {
    await service.addDislikeToMessage(
      userId: userId,
      chatId: chatId,
      messageId: messageId,
    );
    ref.invalidateSelf();
  }

  Future<void> removeDislikeFromMessage({
    required String userId,
    required String chatId,
    required String messageId,
  }) async {
    await service.removeDislikeFromMessage(
      userId: userId,
      chatId: chatId,
      messageId: messageId,
    );
    ref.invalidateSelf();
  }

  Future<void> createMessage({
    required String chatId,
    required DateTime sentAt,
    required String sentBy,
    required ChatContent content,
  }) async {
    await service.createMessage(
      chatId: chatId,
      content: content,
      sentAt: sentAt,
      sentBy: sentBy,
    );
  }

  Future<void> loadMoreChats(String chatId) async {
    if (_isFetchingMore) {
      return;
    }

    final PaginatedChatMessage? currentData = state.value;

    if (currentData == null || !currentData.hasMore) {
      return;
    }

    if (currentData.startAfter == null) {
      return;
    }

    _isFetchingMore = true;

    try {
      final PaginatedChatMessage nextPage = await service.getMoreChat(
        lastDocument: currentData.startAfter!,
        chatId: chatId,
      );

      final List<ChatMessage> updatedChatItems = <ChatMessage>[
        ...currentData.chatMessages,
        ...nextPage.chatMessages,
      ];

      // ignore: always_specify_types
      state = AsyncValue.data(
        PaginatedChatMessage(
          chatMessages: updatedChatItems,
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
