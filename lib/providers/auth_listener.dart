import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'auth.dart';

part 'auth_listener.g.dart';

@riverpod
Stream<void> authListener(Ref ref) async* {
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    ref.read(authProvider.notifier).updateState(user: user);
  });
}
