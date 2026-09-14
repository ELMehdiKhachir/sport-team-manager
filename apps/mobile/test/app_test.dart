import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sport_team_manager/app/app.dart';
import 'package:sport_team_manager/core/auth/auth_gateway.dart';
import 'package:sport_team_manager/core/network/identity_gateway.dart';
import 'package:sport_team_manager/core/network/player_gateway.dart';
import 'package:sport_team_manager/core/network/team_gateway.dart';

void main() {
  testWidgets('shows the sign-in page when signed out', (tester) async {
    await tester.pumpWidget(
      SportTeamManagerApp(
        authGateway: _FakeAuthGateway(),
        identityGateway: _FakeIdentityGateway(),
        teamGateway: _FakeTeamGateway(),
        playerGateway: _FakePlayerGateway(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bienvenue sur le terrain'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
  });

  testWidgets('opens account creation and password reset', (tester) async {
    await tester.pumpWidget(
      SportTeamManagerApp(
        authGateway: _FakeAuthGateway(),
        identityGateway: _FakeIdentityGateway(),
        teamGateway: _FakeTeamGateway(),
        playerGateway: _FakePlayerGateway(),
      ),
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
        identityGateway: _FakeIdentityGateway(),
        teamGateway: _FakeTeamGateway(),
        playerGateway: _FakePlayerGateway(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bonjour Mehdi !'), findsOneWidget);
    expect(find.text('Connexion sécurisée validée'), findsOneWidget);
    expect(find.text('Crée ton espace équipe'), findsOneWidget);
    expect(find.byTooltip('Se déconnecter'), findsOneWidget);
  });

  testWidgets('creates and then displays the first team', (tester) async {
    final teamGateway = _FakeTeamGateway();
    await tester.pumpWidget(
      SportTeamManagerApp(
        authGateway: _FakeAuthGateway(
          user: const AuthUser(
            id: 'user-1',
            email: 'coach@example.com',
            displayName: 'Mehdi',
          ),
        ),
        identityGateway: _FakeIdentityGateway(),
        teamGateway: teamGateway,
        playerGateway: _FakePlayerGateway(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.bySemanticsLabel('Nom du club'), 'Mon Club');
    await tester.enterText(
        find.bySemanticsLabel('Nom de l’équipe'), 'Seniors 1');
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Créer mon équipe'));
    await tester.pumpAndSettle();

    expect(teamGateway.createdClubName, 'Mon Club');
    expect(teamGateway.createdTeamName, 'Seniors 1');
    expect(find.text('Seniors 1'), findsOneWidget);
    expect(find.text('Mon Club'), findsOneWidget);
    expect(find.text('Manager'), findsOneWidget);
    expect(find.text('Ouvrir l’effectif'), findsOneWidget);
  });

  testWidgets('switches the active team', (tester) async {
    final teamGateway = _FakeTeamGateway(
      initialTeams: const [
        TeamSummary(
          id: 'team-1',
          name: 'Seniors 1',
          clubId: 'club-1',
          clubName: 'Club A',
          roles: ['OWNER_MANAGER'],
        ),
        TeamSummary(
          id: 'team-2',
          name: 'Seniors 2',
          clubId: 'club-2',
          clubName: 'Club B',
          roles: ['PLAYER'],
        ),
      ],
    );
    await tester.pumpWidget(
      SportTeamManagerApp(
        authGateway: _FakeAuthGateway(
          user: const AuthUser(
            id: 'user-1',
            email: 'coach@example.com',
            displayName: 'Mehdi',
          ),
        ),
        identityGateway: _FakeIdentityGateway(),
        teamGateway: teamGateway,
        playerGateway: _FakePlayerGateway(),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester.widget<Text>(find.byKey(const Key('active-team-name'))).data,
      'Seniors 1',
    );

    await tester.tap(find.byKey(const Key('active-team-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Club B · Seniors 2').last);
    await tester.pumpAndSettle();

    expect(
      tester.widget<Text>(find.byKey(const Key('active-team-name'))).data,
      'Seniors 2',
    );
    expect(find.text('Joueur'), findsOneWidget);
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
  Future<String?> getIdToken() async => 'firebase-token';

  @override
  Future<void> signIn(
      {required String email, required String password}) async {}

  @override
  Future<void> signOut() async {}
}

class _FakeIdentityGateway implements IdentityGateway {
  @override
  Future<ServerIdentity> getCurrentIdentity() async => const ServerIdentity(
        firebaseUid: 'user-1',
        email: 'coach@example.com',
        displayName: 'Mehdi',
      );
}

class _FakeTeamGateway implements TeamGateway {
  _FakeTeamGateway({List<TeamSummary>? initialTeams}) {
    if (initialTeams != null) teams.addAll(initialTeams);
  }

  final teams = <TeamSummary>[];
  String? createdClubName;
  String? createdTeamName;

  @override
  Future<TeamSummary> createClubWithTeam({
    required String clubName,
    required String teamName,
  }) async {
    createdClubName = clubName;
    createdTeamName = teamName;
    final team = TeamSummary(
      id: 'team-1',
      name: teamName,
      clubId: 'club-1',
      clubName: clubName,
      roles: const ['OWNER_MANAGER'],
    );
    teams.add(team);
    return team;
  }

  @override
  Future<List<TeamSummary>> getMyTeams() async => List.of(teams);
}

class _FakePlayerGateway implements PlayerGateway {
  final players = <PlayerSummary>[];

  @override
  Future<List<PlayerSummary>> listPlayers(String teamId) async =>
      players.where((player) => player.teamId == teamId).toList();

  @override
  Future<PlayerSummary> createPlayer({
    required String teamId,
    required String firstName,
    required String lastName,
    required PlayerPosition primaryPosition,
    PlayerPosition? secondaryPosition,
    int? shirtNumber,
    DominantFoot? dominantFoot,
  }) async {
    final player = PlayerSummary(
      id: 'player-${players.length + 1}',
      teamId: teamId,
      firstName: firstName,
      lastName: lastName,
      primaryPosition: primaryPosition,
      secondaryPosition: secondaryPosition,
      shirtNumber: shirtNumber,
      dominantFoot: dominantFoot,
      accountAssociated: false,
    );
    players.add(player);
    return player;
  }

  @override
  Future<PlayerInvitation> createInvitation({
    required String teamId,
    required String playerId,
  }) async =>
      PlayerInvitation(
        token: 'fake-invite-token-that-is-long-enough',
        expiresAt: DateTime(2026, 9, 20),
      );

  @override
  Future<PlayerSummary> claimInvitation(String token) async =>
      players.firstWhere((player) => player.id.isNotEmpty);
}
