import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/auth_user.dart';
import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo;
  StreamSubscription<AuthUser?>? _sub;

  AuthUser? _user;
  AuthUser? get user => _user;
  bool get isAuthenticated => _user != null;

  AuthProvider({AuthRepository? repository})
    : _repo = repository ?? InMemoryAuthRepository() {
    _sub = _repo.authStateChanges().listen((u) {
      _user = u;
      notifyListeners();
    });
  }

  Future<void> signInWithCredentials(String email, String password) async {
    await _repo.signInWithCredentials(email: email, password: password);
  }

  Future<void> signInAsGuest() async {
    await _repo.signInAsGuest();
  }

  Future<void> signOut() async {
    await _repo.signOut();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
