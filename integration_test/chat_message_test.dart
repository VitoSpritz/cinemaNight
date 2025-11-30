import 'package:cinenight/firebase_options.dart';
import 'package:cinenight/model/chat_item.dart';
import 'package:cinenight/model/chat_message.dart';
import 'package:cinenight/model/user_profile.dart';
import 'package:cinenight/repositories/chat_message_repository.dart';
import 'package:cinenight/repositories/chat_repository.dart';
import 'package:cinenight/repositories/user_profile_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:uuid/uuid.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late UserProfileRepository userProfileRepository;
  late ChatRepository chatRepository;
  late ChatMessageRepository chatMessageRepository;
  const Uuid idGen = Uuid();

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    userProfileRepository = UserProfileRepository();
    chatRepository = ChatRepository();
    chatMessageRepository = ChatMessageRepository();
  });

  group('Integration tests with realtime db for Chat messages', () {
    testWidgets('Should create and fetch a chat message', (
      WidgetTester tester,
    ) async {
      final String userId = 'test_${idGen.v4()}';

      final UserProfile newUser = UserProfile(
        age: 24,
        firstLastName: 'Andrea Rossi',
        userId: userId,
      );

      await userProfileRepository.createUser(newUser);

      final String chatId = 'test_${idGen.v4()}';

      final ChatItem newChat = ChatItem(
        createdBy: newUser.userId,
        closesAt: DateTime.now(),
        password: "password123",
        id: chatId,
        name: "Test Chat",
        state: ChatItemState.opened.name,
        description: "Test Description",
      );

      await chatRepository.createChat(newChat);

      final String messageId = 'msg_${idGen.v4()}';

      final ChatMessage newMessage = ChatMessage(
        id: messageId,
        userId: userId,
        sentAt: DateTime.now(),
        content: const ChatContent.text(text: 'Test text'),
      );

      await chatMessageRepository.createChatMessage(
        chatId: chatId,
        message: newMessage,
      );

      final PaginatedChatMessage paginatedMessages = await chatMessageRepository
          .listFirstMessages(chatId: chatId);

      expect(paginatedMessages.chatMessages.length, 1);
      expect(paginatedMessages.chatMessages.first.id, messageId);
      expect(paginatedMessages.chatMessages.first.userId, userId);

      await userProfileRepository.deleteUserProfile(userId);
      // await chatRepository.deleteChat(chatId: chatId, userId: userId);
    });
  });
}
