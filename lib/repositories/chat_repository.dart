import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/chat_item.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createChat(ChatItem chat) async {
    await _firestore.collection('chats').doc(chat.id).set(chat.toJson());
  }

  Future<ChatItem?> getChatById(String chatId) async {
    final DocumentSnapshot<Map<String, dynamic>> result = await _firestore
        .collection('chats')
        .doc(chatId)
        .get();

    if (!result.exists) {
      return null;
    }

    return ChatItem.fromJson(result.data()!);
  }

  Future<PaginatedChatItem> listFirstChat({int pageSize = 10}) async {
    final QuerySnapshot<Map<String, dynamic>> result = await _firestore
        .collection('chats')
        .orderBy('created_at', descending: true)
        .limit(pageSize)
        .get();

    final List<ChatItem> chats = result.docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              ChatItem.fromJson(doc.data()),
        )
        .toList();

    return PaginatedChatItem(
      chatItems: chats,
      startAfter: result.docs.isNotEmpty ? result.docs.last : null,
      hasMore: result.docs.length == pageSize,
    );
  }

  Future<PaginatedChatItem> listPaginatedChat({
    required DocumentSnapshot lastDocument,
    int pageSize = 10,
  }) async {
    final QuerySnapshot<Map<String, dynamic>> result = await _firestore
        .collection('chats')
        .orderBy('created_at', descending: true)
        .startAfterDocument(lastDocument)
        .limit(pageSize)
        .get();

    final List<ChatItem> chats = result.docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              ChatItem.fromJson(doc.data()),
        )
        .toList();

    return PaginatedChatItem(
      chatItems: chats,
      startAfter: result.docs.isNotEmpty ? result.docs.last : null,
      hasMore: result.docs.length == pageSize,
    );
  }

  Future<void> deleteChat({
    required String userId,
    required String chatId,
  }) async {
    final QuerySnapshot<Map<String, dynamic>> usersWithChat = await _firestore
        .collection('users')
        .where('savedChats', arrayContains: chatId)
        .get();

    final WriteBatch batch = _firestore.batch();

    for (QueryDocumentSnapshot<Map<String, dynamic>> userDoc
        in usersWithChat.docs) {
      batch.update(userDoc.reference, <String, dynamic>{
        'savedChats': FieldValue.arrayRemove(<dynamic>[chatId]),
      });
    }

    batch.delete(_firestore.collection('chats').doc(chatId));

    await batch.commit();

    await _firestore.collection('chats').doc(chatId).delete();
  }
}
