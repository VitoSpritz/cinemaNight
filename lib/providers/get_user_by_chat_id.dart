import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/user_profile.dart';
import '../services/user_service.dart';

part 'get_user_by_chat_id.g.dart';

@riverpod
Future<List<UserProfile>> getUsersByChat(
  Ref ref, {
  required String chatId,
}) async {
  final UserService service = UserService();

  return await service.getUsersByChat(chatId: chatId);
}
