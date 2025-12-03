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

  Future<List<ChatItem>> getChatByName({required String chatName}) async {
    final QuerySnapshot<Map<String, dynamic>> result = await _firestore
        .collection('chats')
        .where('name', isEqualTo: chatName)
        .get();

    if (result.docs.isEmpty) {
      return <ChatItem>[];
    }

    return result.docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              ChatItem.fromJson(doc.data()),
        )
        .toList();
  }

  Future<List<ChatItem>> getChatsByUserId({required String userId}) async {
    final DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestore
        .collection('users')
        .doc(userId)
        .get();

    if (!userDoc.exists) {
      return <ChatItem>[];
    }

    final List<String> chatIds = List<String>.from(
      userDoc.data()?['savedChats'] ?? <dynamic>[],
    );

    if (chatIds.isEmpty) {
      return <ChatItem>[];
    }

    final List<ChatItem> allChats = <ChatItem>[];

    for (int i = 0; i < chatIds.length; i += 10) {
      final List<String> batch = chatIds.skip(i).take(10).toList();

      final QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('chats')
          .where(FieldPath.documentId, whereIn: batch)
          .get();

      allChats.addAll(
        querySnapshot.docs
            .map(
              (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                  ChatItem.fromJson(doc.data()),
            )
            .toList(),
      );
    }

    return allChats;
  }

  Future<PaginatedChatItem> listFirstChat({int pageSize = 10}) async {
    final QuerySnapshot<Map<String, dynamic>> result = await _firestore
        .collection('chats')
        .orderBy('name', descending: true)
        .limit(pageSize + 1)
        .get();

    final bool hasMore = result.docs.length > pageSize;
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docsToUse = hasMore
        ? result.docs.sublist(0, pageSize)
        : result.docs;

    final List<ChatItem> chats = docsToUse
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              ChatItem.fromJson(doc.data()),
        )
        .toList();

    return PaginatedChatItem(
      chatItems: chats,
      startAfter: docsToUse.isNotEmpty ? docsToUse.last : null,
      hasMore: hasMore,
    );
  }

  Future<PaginatedChatItem> listPaginatedChat({
    required DocumentSnapshot lastDocument,
    int pageSize = 10,
  }) async {
    final QuerySnapshot<Map<String, dynamic>> result = await _firestore
        .collection('chats')
        .orderBy('name', descending: true)
        .startAfterDocument(lastDocument)
        .limit(pageSize + 1)
        .get();

    final bool hasMore = result.docs.length > pageSize;
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docsToUse = hasMore
        ? result.docs.sublist(0, pageSize)
        : result.docs;

    final List<ChatItem> chats = docsToUse
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              ChatItem.fromJson(doc.data()),
        )
        .toList();

    return PaginatedChatItem(
      chatItems: chats,
      startAfter: docsToUse.isNotEmpty ? docsToUse.last : null,
      hasMore: hasMore,
    );
  }

  Future<void> updateChat({
    required String chatId,
    required ChatItem updatedChat,
  }) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .update(updatedChat.toJson());
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
  }
}
