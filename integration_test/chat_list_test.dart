import 'package:cinenight/firebase_options.dart';
import 'package:cinenight/model/chat_item.dart';
import 'package:cinenight/model/user_profile.dart';
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
  const Uuid idGen = Uuid();

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    userProfileRepository = UserProfileRepository();
    chatRepository = ChatRepository();
  });

  group('Integration tests with realtime db for Chat list', () {
    testWidgets('Should create a chat', (WidgetTester tester) async {
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
        createdAt: DateTime.now(),
        id: chatId,
        name: "Test",
        state: ChatItemState.opened.name,
        description: "Descizione",
      );

      await chatRepository.createChat(newChat);

      final ChatItem? fetchedChat = await chatRepository.getChatById(chatId);

      expect(fetchedChat, isNotNull);
      expect(fetchedChat?.id, chatId);

      final PaginatedChatItem paginatedChatItems = await chatRepository
          .listFirstChat();
      expect(paginatedChatItems.chatItems.length, 1);

      await userProfileRepository.deleteUserProfile(userId);
      await chatRepository.deleteChat(chatId: chatId);
    });
  });
}
