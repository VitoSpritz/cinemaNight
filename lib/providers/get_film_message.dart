import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/chat_message.dart';
import '../services/chat_messages.dart';

part 'get_film_message.g.dart';

@riverpod
Future<ChatMessage?> getFilmMessage(
  Ref ref,
  String userId,
  String chatId,
) async {
  final ChatMessages service = ChatMessages();
  return await service.getUserFilmMessage(userId: userId, chatId: chatId);
}
