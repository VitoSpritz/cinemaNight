import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/user_profile.dart';
import '../services/user_service.dart';
import 'auth.dart';

part 'user_profiles.g.dart';

@riverpod
class UserProfiles extends _$UserProfiles {
  final UserService service = UserService();

  @override
  Future<UserProfile> build() async {
    final User? user = ref.watch(authProvider);
    return await service.getUserById(user?.uid);
  }

  Future<void> createUserProfile({
    required String userId,
    required String name,
    int? age,
    String? imageUrl,
  }) async {
    await service.createUserProfile(
      name: name,
      userId: userId,
      age: age,
      imageUrl: imageUrl,
    );
    ref.invalidateSelf();
  }

  Future<void> updateUserProfile({
    required String userId,
    required String name,
    int? age,
    String? imageUrl,
    String? preferredFilm,
  }) async {
    await service.udpateUser(
      name: name,
      userId: userId,
      age: age,
      imageUrl: imageUrl,
      preferredFilm: preferredFilm,
    );
    ref.invalidateSelf();
  }
}
