import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Authenticator extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _authSubscription;
  User? _user;
  bool _isInitialized = false;

  Authenticator() {
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      _user = user;
      _isInitialized = true;
      notifyListeners();
    });
  }

  bool get isAuthenticated => _user != null;
  bool get isInitialized => _isInitialized;
  User? get user => _user;

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
