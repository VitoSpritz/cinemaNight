import 'dart:async';

import '../model/user_profile.dart';
import '../repositories/user_profile_repository.dart';

class UserService {
  final UserProfileRepository _repository = UserProfileRepository();

  Future<UserProfile> createUserProfile({
    required String name,
    required String userId,
    int? age,
    String? imageUrl,
  }) async {
    final UserProfile newUser = UserProfile(
      userId: userId,
      firstLastName: name,
      age: age,
      imageUrl: imageUrl,
    );
    await _repository.createUser(newUser);

    return await getUserById(userId);
  }

  Future<UserProfile> getUserById(String? userId) async {
    if (userId == null) {
      throw Exception("User does not exist");
    }
    final UserProfile? gotUser = await _repository.getUserById(userId);
    return gotUser!;
  }

  Future<UserProfile> udpateUser({
    required String userId,
    required String name,
    int? age,
    String? imageUrl,
    String? preferredFilm,
  }) async {
    final UserProfile update = UserProfile(
      userId: userId,
      age: age,
      firstLastName: name,
      imageUrl: imageUrl,
      preferredFilm: preferredFilm,
    );
    await _repository.updateUserProfile(userId, update);

    return getUserById(userId);
  }

  Future<void> deleteUser(String userId) async {
    await _repository.deleteUserProfile(userId);
    return;
  }
}
