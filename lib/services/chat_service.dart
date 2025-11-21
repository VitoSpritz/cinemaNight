import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../model/chat_item.dart';
import '../repositories/chat_repository.dart';

class ChatService {
  final ChatRepository _chatRepository = ChatRepository();

  Future<ChatItem> createChat({
    required String createdBy,
    required DateTime closesAt,
    required String name,
    required String password,
    required String? description,
  }) async {
    final ChatItem chatItem = ChatItem(
      id: const Uuid().v4(),
      createdBy: createdBy,
      name: name,
      state: ChatItemState.opened.name,
      closesAt: closesAt,
      password: password,
      description: description,
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

  Future<PaginatedChatItem> getFirstChatPage({int? pageSize}) async {
    return await _chatRepository.listFirstChat(pageSize: pageSize ?? 10);
  }

  Future<PaginatedChatItem> getMoreChat({
    required DocumentSnapshot lastDocument,
  }) async {
    return await _chatRepository.listPaginatedChat(lastDocument: lastDocument);
  }

  Future<void> deleteChat({
    required String userId,
    required String chatId,
  }) async {
    return await _chatRepository.deleteChat(userId: userId, chatId: chatId);
  }
}
