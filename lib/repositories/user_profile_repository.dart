import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/user_profile.dart';

class UserProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser(UserProfile user) async {
    await _firestore.collection('users').doc(user.userId).set(user.toJson());
  }

  Future<UserProfile?> getUserById(String userId) async {
    final DocumentSnapshot<Map<String, dynamic>> result = await _firestore
        .collection('users')
        .doc(userId)
        .get();

    if (!result.exists) {
      return null;
    }

    return UserProfile.fromJson(result.data()!);
  }

  Future<void> updateUserProfile(String userId, UserProfile userUpdate) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .update(userUpdate.toJson());
  }

  Future<void> deleteUserProfile(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }
}
