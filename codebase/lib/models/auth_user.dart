class AuthUser {
  final String id;
  final String? email;
  final String displayName;
  final bool isGuest;

  const AuthUser({
    required this.id,
    required this.displayName,
    this.email,
    this.isGuest = false,
  });
}
