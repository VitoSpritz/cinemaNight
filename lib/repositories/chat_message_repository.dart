import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/chat_message.dart';

class ChatMessageRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createChatMessage({
    required String chatId,
    required ChatMessage message,
  }) async {
    _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(message.id)
        .set(message.toJson());
  }

  Future<PaginatedChatMessage> listFirstMessages({
    required String chatId,
    int pageSize = 10,
  }) async {
    final QuerySnapshot<Map<String, dynamic>> result = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sent_at', descending: true)
        .limit(pageSize)
        .get();

    final List<ChatMessage> chats = result.docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              ChatMessage.fromJson(doc.data()),
        )
        .toList();

    return PaginatedChatMessage(
      chatMessages: chats,
      startAfter: result.docs.isNotEmpty ? result.docs.last : null,
      hasMore: result.docs.length == pageSize,
    );
  }

  Future<PaginatedChatMessage> listPaginatedChat({
    required String chatId,
    required DocumentSnapshot lastDocument,
    int pageSize = 10,
  }) async {
    final QuerySnapshot<Map<String, dynamic>> result = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sent_at', descending: true)
        .startAfterDocument(lastDocument)
        .limit(pageSize)
        .get();

    final List<ChatMessage> chats = result.docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              ChatMessage.fromJson(doc.data()),
        )
        .toList();

    return PaginatedChatMessage(
      chatMessages: chats,
      startAfter: result.docs.isNotEmpty ? result.docs.last : null,
      hasMore: result.docs.length == pageSize,
    );
  }

  Stream<List<ChatMessage>> watchMessages({
    required String chatId,
    int pageSize = 50,
  }) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sent_at', descending: true)
        .limit(pageSize)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
          return snapshot.docs
              .map(
                (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                    ChatMessage.fromJson(doc.data()),
              )
              .toList();
        });
  }

  Future<void> addMessageDates({
    required String userId,
    required String chatId,
    required String messageId,
  }) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update(<Object, Object?>{
          'content.likes': FieldValue.arrayUnion(<dynamic>[userId]),
        });
  }

  Future<void> removeMessageDates({
    required String userId,
    required String chatId,
    required String messageId,
  }) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update(<Object, Object?>{
          'content.likes': FieldValue.arrayRemove(<dynamic>[userId]),
        });
  }
}
