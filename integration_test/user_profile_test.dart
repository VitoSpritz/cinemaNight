// integration_test/user_profile_test.dart
import 'package:cinenight/firebase_options.dart';
import 'package:cinenight/model/user_profile.dart';
import 'package:cinenight/repositories/user_profile_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:uuid/uuid.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late UserProfileRepository userProfileRepository;
  const Uuid idGen = Uuid();

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    userProfileRepository = UserProfileRepository();
  });

  group('Integration tests with real Firebase', () {
    testWidgets('Should create and fetch user', (WidgetTester tester) async {
      final String id = 'test_${idGen.v4()}';

      final UserProfile newUser = UserProfile(
        age: 24,
        firstLastName: 'Andrea Rossi',
        userId: id,
        preferredFilm: "Toy story",
      );

      await userProfileRepository.createUser(newUser);

      final UserProfile? fetchedUser = await userProfileRepository.getUserById(
        id,
      );

      expect(fetchedUser, isNotNull);
      expect(fetchedUser?.userId, equals(id));

      await userProfileRepository.deleteUserProfile(id);
    });

    testWidgets('Should be able to update a user', (WidgetTester tester) async {
      final String id = 'test_${idGen.v4()}';

      final UserProfile newUser = UserProfile(
        age: 24,
        firstLastName: 'Andrea Rossi',
        userId: id,
      );

      await userProfileRepository.createUser(newUser);

      final UserProfile userUpdate = UserProfile(
        userId: id,
        age: 47,
        firstLastName: "Antonio Verdi",
      );

      await userProfileRepository.updateUserProfile(id, userUpdate);

      final UserProfile? gotUser = await userProfileRepository.getUserById(id);

      expect(gotUser!.age, 47);
      expect(gotUser.firstLastName, "Antonio Verdi");

      await userProfileRepository.deleteUserProfile(id);
    });
  });
}
