import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../model/chat_item.dart';
import '../model/chat_message.dart';
import '../repositories/chat_repository.dart';

class ChatService {
  final ChatRepository _chatRepository = ChatRepository();

  Future<ChatItem> createChat({
    required String createdBy,
    required DateTime closesAt,
    required String name,
    required String password,
    required String? description,
    DateTime? endDateSelection,
  }) async {
    final ChatItem chatItem = ChatItem(
      id: const Uuid().v4(),
      createdBy: createdBy,
      name: name,
      state: ChatItemState.opened.name,
      closesAt: closesAt,
      password: password,
      description: description,
      endDateSelection: endDateSelection,
    );

    await _chatRepository.createChat(chatItem);

    return await getChatById(chatId: chatItem.id);
  }

  Future<ChatItem> getChatById({required String chatId}) async {
    final ChatItem? chat = await _chatRepository.getChatById(chatId);
    if (chat == null) {
      throw Exception("Chat not found");
    }
    return chat;
  }

  Future<List<ChatItem>> getChatByName({required String chatName}) async {
    final List<ChatItem> chat = await _chatRepository.getChatByName(
      chatName: chatName,
    );
    return chat;
  }

  Future<PaginatedChatItem> getFirstChatPage({int? pageSize}) async {
    return await _chatRepository.listFirstChat(pageSize: pageSize ?? 10);
  }

  Future<PaginatedChatItem> getMoreChat({
    required DocumentSnapshot lastDocument,
  }) async {
    return await _chatRepository.listPaginatedChat(lastDocument: lastDocument);
  }

  Future<({ChatMessage? topDateMessage, ChatMessage? topFilmMessage})>
  getMostLikedMessages({required String chatId}) async {
    return _chatRepository.getMostLikedMessages(chatId: chatId);
  }

  Future<PaginatedChatItem> getChatsByUser({required String userId}) async {
    final List<ChatItem> chats = await _chatRepository.getChatsByUserId(
      userId: userId,
    );
    return PaginatedChatItem(
      chatItems: chats,
      hasMore: false,
      startAfter: null,
    );
  }

  Future<ChatItem> updateChat({
    required String chatId,
    required ChatItem updatedChat,
  }) async {
    await _chatRepository.updateChat(chatId: chatId, updatedChat: updatedChat);

    return await getChatById(chatId: chatId);
  }

  Future<void> deleteChat({
    required String userId,
    required String chatId,
  }) async {
    return await _chatRepository.deleteChat(userId: userId, chatId: chatId);
  }
}
