import 'package:flutter_test/flutter_test.dart';
import 'package:sport_team_manager/app/app.dart';
import 'package:sport_team_manager/core/auth/auth_gateway.dart';

void main() {
  testWidgets('shows the sign-in page when signed out', (tester) async {
    await tester.pumpWidget(
      SportTeamManagerApp(authGateway: _FakeAuthGateway()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bienvenue sur le terrain'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
  });

  testWidgets('opens account creation and password reset', (tester) async {
    await tester.pumpWidget(
      SportTeamManagerApp(authGateway: _FakeAuthGateway()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pas encore de compte ? Créer un compte'));
    await tester.pumpAndSettle();
    expect(find.text('Créer mon compte'), findsWidgets);
    expect(find.text('Prénom et nom'), findsOneWidget);

    await tester.tap(find.text('Retour à la connexion'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mot de passe oublié ?'));
    await tester.pumpAndSettle();
    expect(find.text('Mot de passe oublié'), findsOneWidget);
    expect(find.text('Envoyer le lien'), findsOneWidget);
  });

  testWidgets('shows the home page when signed in', (tester) async {
    await tester.pumpWidget(
      SportTeamManagerApp(
        authGateway: _FakeAuthGateway(
          user: const AuthUser(
            id: 'user-1',
            email: 'coach@example.com',
            displayName: 'Mehdi',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bonjour Mehdi !'), findsOneWidget);
    expect(find.byTooltip('Se déconnecter'), findsOneWidget);
  });
}

class _FakeAuthGateway implements AuthGateway {
  _FakeAuthGateway({this.user});

  final AuthUser? user;

  @override
  Stream<AuthUser?> get userChanges => Stream.value(user);

  @override
  Future<void> register({
    required String displayName,
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> signIn(
      {required String email, required String password}) async {}

  @override
  Future<void> signOut() async {}
}
