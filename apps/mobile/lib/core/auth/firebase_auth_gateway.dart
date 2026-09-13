import 'package:firebase_auth/firebase_auth.dart';
import 'package:sport_team_manager/core/auth/auth_gateway.dart';

class FirebaseAuthGateway implements AuthGateway {
  FirebaseAuthGateway({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance {
    userChanges = _firebaseAuth.userChanges().map(_toAuthUser);
  }

  final FirebaseAuth _firebaseAuth;

  @override
  late final Stream<AuthUser?> userChanges;

  static AuthUser? _toAuthUser(User? user) {
    if (user == null) return null;
    return AuthUser(
      id: user.uid,
      email: user.email,
      displayName: user.displayName,
    );
  }

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  @override
  Future<void> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await credential.user?.updateDisplayName(displayName.trim());
  }

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _firebaseAuth.sendPasswordResetEmail(email: email.trim());

  @override
  Future<void> signOut() => _firebaseAuth.signOut();
}
