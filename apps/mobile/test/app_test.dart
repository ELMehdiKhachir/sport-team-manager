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
        teamGateway: _FakeTeamGateway(
          initialTeams: const [
            TeamSummary(
              id: 'team-1',
              name: 'Seniors 1',
              clubName: 'Club A',
              roles: ['OWNER_MANAGER'],
              permissions: [
                TeamPermission.viewRoster,
                TeamPermission.manageRoster,
                TeamPermission.manageTeamMembers,
              ],
            ),
          ],
        ),
        playerGateway: _FakePlayerGateway(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bonjour Mehdi !'), findsOneWidget);
    expect(find.byKey(const Key('home-team-context')), findsOneWidget);
    expect(find.text('Seniors 1'), findsOneWidget);
    expect(find.text('Club A'), findsOneWidget);
    expect(find.text('Manager'), findsOneWidget);
    expect(find.text('Aucune action à traiter'), findsOneWidget);
    expect(find.text('Prochaines échéances'), findsOneWidget);
    expect(find.text('Crée ton espace équipe'), findsNothing);
    expect(find.text('Ouvrir l’effectif'), findsNothing);
  });

  testWidgets(
    'opens Team from the home priority action without a team',
    (tester) async {
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

      expect(find.text('Crée ton espace équipe'), findsOneWidget);
      await tester.tap(find.byKey(const Key('home-create-team')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('team-page')), findsOneWidget);
      expect(find.text('Créer mon équipe'), findsOneWidget);
    },
  );

  testWidgets('navigates between the five main sections', (tester) async {
    final authGateway = _FakeAuthGateway(
      user: const AuthUser(
        id: 'user-1',
        email: 'coach@example.com',
        displayName: 'Mehdi',
      ),
    );
    await tester.pumpWidget(
      SportTeamManagerApp(
        authGateway: authGateway,
        identityGateway: _FakeIdentityGateway(),
        teamGateway: _FakeTeamGateway(),
        playerGateway: _FakePlayerGateway(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byKey(const Key('nav-home')), findsOneWidget);
    expect(find.byKey(const Key('nav-calendar')), findsOneWidget);
    expect(find.byKey(const Key('nav-team')), findsOneWidget);
    expect(find.byKey(const Key('nav-stats')), findsOneWidget);
    expect(find.byKey(const Key('nav-profile')), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav-calendar')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('calendar-page')), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav-team')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('team-page')), findsOneWidget);
    expect(find.text('Crée ton espace équipe'), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav-stats')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('stats-page')), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav-profile')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('profile-page')), findsOneWidget);
    expect(find.text('Mehdi'), findsOneWidget);
    expect(find.text('coach@example.com'), findsOneWidget);

    await tester.tap(find.byKey(const Key('profile-sign-out')));
    await tester.pumpAndSettle();
    expect(authGateway.signedOut, isTrue);
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

    await tester.tap(find.byKey(const Key('nav-team')));
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
          permissions: [
            TeamPermission.viewRoster,
            TeamPermission.manageRoster,
            TeamPermission.invitePlayer,
            TeamPermission.manageTeamMembers,
          ],
        ),
        TeamSummary(
          id: 'team-2',
          name: 'Seniors 2',
          clubId: 'club-2',
          clubName: 'Club B',
          roles: ['PLAYER'],
          permissions: [
            TeamPermission.viewRoster,
            TeamPermission.respondAvailability,
          ],
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

    await tester.tap(find.byKey(const Key('nav-team')));
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

    await tester.tap(find.byKey(const Key('nav-profile')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nav-home')));
    await tester.pumpAndSettle();
    expect(find.text('Aucune action à traiter'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('home-active-team-name'))).data,
      'Seniors 2',
    );
    expect(find.text('Joueur'), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav-team')));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Text>(find.byKey(const Key('active-team-name'))).data,
      'Seniors 2',
    );
  });

  testWidgets(
    'uses API permissions for roster management actions',
    (tester) async {
      final playerGateway = _FakePlayerGateway(
        initialPlayers: const [
          PlayerSummary(
            id: 'player-1',
            teamId: 'team-1',
            firstName: 'Amine',
            lastName: 'Benali',
            primaryPosition: PlayerPosition.pivot,
            accountAssociated: false,
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
          teamGateway: _FakeTeamGateway(
            initialTeams: const [
              TeamSummary(
                id: 'team-1',
                name: 'Seniors 1',
                clubName: 'Club A',
                roles: ['OWNER_MANAGER'],
                permissions: [
                  TeamPermission.viewRoster,
                  TeamPermission.manageRoster,
                  TeamPermission.invitePlayer,
                  TeamPermission.manageTeamMembers,
                ],
              ),
            ],
          ),
          playerGateway: playerGateway,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('nav-team')));
      await tester.pumpAndSettle();

      expect(find.text('Inviter un coach ou un staff'), findsOneWidget);
      await tester.tap(find.text('Ouvrir l’effectif'));
      await tester.pumpAndSettle();

      expect(find.text('Ajouter un joueur'), findsOneWidget);
      expect(find.text('Modifier'), findsOneWidget);
      expect(find.text('Désactiver'), findsOneWidget);
      expect(find.text('Inviter'), findsOneWidget);

      await tester.tap(find.text('Modifier'));
      await tester.pumpAndSettle();
      expect(find.text('Modifier le joueur'), findsOneWidget);
      await tester.enterText(find.bySemanticsLabel('Nom'), 'Kaci');
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      expect(playerGateway.updatedPlayerId, 'player-1');
      expect(find.text('Amine Kaci'), findsOneWidget);

      await tester.tap(find.text('Désactiver'));
      await tester.pumpAndSettle();
      expect(find.text('Désactiver Amine ?'), findsOneWidget);
      await tester.tap(find.text('Désactiver').last);
      await tester.pumpAndSettle();

      expect(playerGateway.players.single.active, isFalse);
      expect(find.text('Inactif'), findsOneWidget);
      expect(find.text('Réactiver'), findsOneWidget);
    },
  );

  testWidgets(
    'hides roster management actions without API permissions',
    (tester) async {
      final playerGateway = _FakePlayerGateway(
        initialPlayers: const [
          PlayerSummary(
            id: 'player-1',
            teamId: 'team-1',
            firstName: 'Amine',
            lastName: 'Benali',
            primaryPosition: PlayerPosition.pivot,
            accountAssociated: false,
          ),
        ],
      );
      await tester.pumpWidget(
        SportTeamManagerApp(
          authGateway: _FakeAuthGateway(
            user: const AuthUser(
              id: 'user-1',
              email: 'player@example.com',
              displayName: 'Amine',
            ),
          ),
          identityGateway: _FakeIdentityGateway(),
          teamGateway: _FakeTeamGateway(
            initialTeams: const [
              TeamSummary(
                id: 'team-1',
                name: 'Seniors 1',
                clubName: 'Club A',
                roles: ['PLAYER'],
                permissions: [
                  TeamPermission.viewRoster,
                  TeamPermission.respondAvailability,
                ],
              ),
            ],
          ),
          playerGateway: playerGateway,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('nav-team')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ouvrir l’effectif'));
      await tester.pumpAndSettle();

      expect(find.text('Ajouter un joueur'), findsNothing);
      expect(find.text('Modifier'), findsNothing);
      expect(find.text('Désactiver'), findsNothing);
      expect(find.text('Réactiver'), findsNothing);
      expect(find.text('Inviter'), findsNothing);
      expect(find.text('Inviter un coach ou un staff'), findsNothing);
    },
  );
}

class _FakeAuthGateway implements AuthGateway {
  _FakeAuthGateway({this.user});

  final AuthUser? user;
  bool signedOut = false;

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
  Future<void> signOut() async {
    signedOut = true;
  }
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
      permissions: const [
        TeamPermission.viewRoster,
        TeamPermission.manageRoster,
        TeamPermission.invitePlayer,
        TeamPermission.manageTeamMembers,
      ],
    );
    teams.add(team);
    return team;
  }

  @override
  Future<List<TeamSummary>> getMyTeams() async => List.of(teams);

  @override
  Future<TeamMemberInvitation> createMemberInvitation({
    required String teamId,
    required TeamInvitationRole role,
  }) async =>
      TeamMemberInvitation(
        token: 'fake-team-invitation-token-that-is-long-enough',
        role: role,
        expiresAt: DateTime(2026, 9, 22),
      );

  @override
  Future<TeamSummary> claimMemberInvitation(String token) async =>
      const TeamSummary(
        id: 'team-joined',
        name: 'Seniors 2',
        roles: ['COACH'],
        permissions: [
          TeamPermission.viewRoster,
          TeamPermission.manageRoster,
        ],
      );
}

class _FakePlayerGateway implements PlayerGateway {
  _FakePlayerGateway({List<PlayerSummary>? initialPlayers}) {
    if (initialPlayers != null) players.addAll(initialPlayers);
  }

  final players = <PlayerSummary>[];
  String? updatedPlayerId;

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
  Future<PlayerSummary> updatePlayer({
    required String teamId,
    required String playerId,
    required String firstName,
    required String lastName,
    required PlayerPosition primaryPosition,
    PlayerPosition? secondaryPosition,
    int? shirtNumber,
    DominantFoot? dominantFoot,
    bool? active,
  }) async {
    final index = players.indexWhere(
      (player) => player.id == playerId && player.teamId == teamId,
    );
    final current = players[index];
    final updated = PlayerSummary(
      id: current.id,
      teamId: current.teamId,
      firstName: firstName,
      lastName: lastName,
      primaryPosition: primaryPosition,
      secondaryPosition: secondaryPosition,
      shirtNumber: shirtNumber,
      dominantFoot: dominantFoot,
      active: active ?? current.active,
      accountAssociated: current.accountAssociated,
    );
    players[index] = updated;
    updatedPlayerId = playerId;
    return updated;
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
