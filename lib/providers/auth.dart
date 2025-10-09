import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth.g.dart';

@riverpod
class Auth extends _$Auth {
  @override
  User? build() {
    return FirebaseAuth.instance.currentUser;
  }

  bool isAuthenticated() {
    return FirebaseAuth.instance.currentUser != null;
  }

  void updateState({required User? user}) {
    state = user;
  }
}
