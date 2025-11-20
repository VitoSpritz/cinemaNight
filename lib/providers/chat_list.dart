import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/chat_item.dart';
import '../services/chat_service.dart';

part 'chat_list.g.dart';

@riverpod
class ChatList extends _$ChatList {
  final ChatService service = ChatService();

  @override
  Future<PaginatedChatItem> build() async {
    return await service.getFirstChatPage();
  }

  Future<void> createChat({
    required String createdBy,
    required DateTime createdAt,
    required String name,
    required String password,
    required String? description,
  }) async {
    await service.createChat(
      createdBy: createdBy,
      createdAt: createdAt,
      name: name,
      password: password,
      description: description,
    );
    ref.invalidateSelf();
  }

  Future<PaginatedChatItem> listMoreChat({
    required DocumentSnapshot lastDocument,
  }) async {
    return await service.getMoreChat(lastDocument: lastDocument);
  }
}
