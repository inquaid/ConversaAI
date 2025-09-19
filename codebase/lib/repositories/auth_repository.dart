import 'dart:async';

import '../models/auth_user.dart';

abstract class AuthRepository {
  Stream<AuthUser?> authStateChanges();
  Future<AuthUser> signInWithCredentials({
    required String email,
    required String password,
  });
  Future<AuthUser> signInAsGuest();
  Future<void> signOut();
  AuthUser? get currentUser;
}

class InMemoryAuthRepository implements AuthRepository {
  AuthUser? _currentUser;
  final StreamController<AuthUser?> _controller =
      StreamController<AuthUser?>.broadcast();

  InMemoryAuthRepository();

  // Private getter to common stream (controller's stream).
  Stream<AuthUser?> get _authStream => _controller.stream;

  @override
  Stream<AuthUser?> authStateChanges() => _authStream;

  void _emit(AuthUser? user) {
    _currentUser = user;
    _controller.add(user);
  }

  @override
  Future<AuthUser> signInWithCredentials({
    required String email,
    required String password,
  }) async {
    // Fake credential check; replace later
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final user = AuthUser(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      email: email,
      displayName: email.split('@').first,
      isGuest: false,
    );
    _emit(user);
    return user;
  }

  @override
  Future<AuthUser> signInAsGuest() async {
    final user = AuthUser(
      id: 'guest-${DateTime.now().microsecondsSinceEpoch}',
      email: null,
      displayName: 'Guest',
      isGuest: true,
    );
    _emit(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    _emit(null);
  }

  @override
  AuthUser? get currentUser => _currentUser;
}
