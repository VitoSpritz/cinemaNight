import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../model/chat_message.dart';
import '../repositories/chat_message_repository.dart';

class ChatMessages {
  final ChatMessageRepository _messageRepository = ChatMessageRepository();

  Future<void> createMessage({
    required String chatId,
    required DateTime sentAt,
    required String sentBy,
    required ChatContent content,
  }) async {
    final String id = const Uuid().v4();

    final ChatMessage newMessage = ChatMessage(
      id: id,
      userId: sentBy,
      sentAt: sentAt,
      content: content,
    );

    await _messageRepository.createChatMessage(
      chatId: chatId,
      message: newMessage,
    );
  }

  Future<PaginatedChatMessage> getFirstChatPage({
    required String chatId,
    int? pageSize,
  }) async {
    return await _messageRepository.listFirstMessages(
      chatId: chatId,
      pageSize: pageSize ?? 10,
    );
  }

  Future<PaginatedChatMessage> getMoreChat({
    required String chatId,
    required DocumentSnapshot lastDocument,
  }) async {
    return await _messageRepository.listPaginatedChat(
      chatId: chatId,
      lastDocument: lastDocument,
    );
  }

  Future<void> addLikeToMessage({
    required String userId,
    required String chatId,
    required String messageId,
  }) async {
    await _messageRepository.addLikeToMessage(
      userId: userId,
      chatId: chatId,
      messageId: messageId,
    );
  }

  Future<void> removeLikeFromMessage({
    required String userId,
    required String chatId,
    required String messageId,
  }) async {
    await _messageRepository.removeLikeFromMessage(
      userId: userId,
      chatId: chatId,
      messageId: messageId,
    );
  }

  Future<void> addDislikeToMessage({
    required String userId,
    required String chatId,
    required String messageId,
  }) async {
    await _messageRepository.addDislikeToMessage(
      userId: userId,
      chatId: chatId,
      messageId: messageId,
    );
  }

  Future<void> removeDislikeFromMessage({
    required String userId,
    required String chatId,
    required String messageId,
  }) async {
    await _messageRepository.removeDislikeFromMessage(
      userId: userId,
      chatId: chatId,
      messageId: messageId,
    );
  }

  Future<ChatMessage?> getUserFilmMessage({
    required String userId,
    required String chatId,
  }) async {
    return _messageRepository.getUserFilmMessage(
      userId: userId,
      chatId: chatId,
    );
  }

  Stream<List<ChatMessage>> watchMessages({required String chatId}) {
    return _messageRepository.watchMessages(chatId: chatId);
  }
}
