class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    this.displayName,
  });

  final String id;
  final String? email;
  final String? displayName;
}

abstract interface class AuthGateway {
  Stream<AuthUser?> get userChanges;

  Future<void> signIn({required String email, required String password});

  Future<void> register({
    required String displayName,
    required String email,
    required String password,
  });

  Future<void> sendPasswordResetEmail(String email);

  Future<String?> getIdToken();

  Future<void> signOut();
}
