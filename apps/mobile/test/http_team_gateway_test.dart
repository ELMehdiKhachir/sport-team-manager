import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sport_team_manager/core/network/http_team_gateway.dart';
import 'package:sport_team_manager/core/network/team_gateway.dart';

void main() {
  test('lists the teams of the authenticated user', () async {
    final gateway = HttpTeamGateway(
      baseUrl: 'https://api.example.com',
      idTokenProvider: () async => 'valid-token',
      client: MockClient((request) async {
        expect(request.url.toString(), 'https://api.example.com/teams/mine');
        expect(request.headers['Authorization'], 'Bearer valid-token');
        return http.Response(
          '[{"id":"team-1","name":"Seniors 1",'
          '"club":{"id":"club-1","name":"Mon Club"},'
          '"roles":["OWNER_MANAGER"],'
          '"permissions":["VIEW_ROSTER","MANAGE_ROSTER","INVITE_PLAYER"]}]',
          200,
        );
      }),
    );

    final teams = await gateway.getMyTeams();

    expect(teams.single.name, 'Seniors 1');
    expect(teams.single.clubName, 'Mon Club');
    expect(teams.single.roles, ['OWNER_MANAGER']);
    expect(teams.single.permissions, [
      TeamPermission.viewRoster,
      TeamPermission.manageRoster,
      TeamPermission.invitePlayer,
    ]);
  });

  test('creates a club with its first team', () async {
    final gateway = HttpTeamGateway(
      baseUrl: 'https://api.example.com',
      idTokenProvider: () async => 'valid-token',
      client: MockClient((request) async {
        expect(request.url.toString(), 'https://api.example.com/clubs');
        expect(request.method, 'POST');
        expect(request.headers['Authorization'], 'Bearer valid-token');
        expect(request.body, '{"clubName":"Mon Club","teamName":"Seniors 1"}');
        return http.Response(
          '{"club":{"id":"club-1","name":"Mon Club"},'
          '"team":{"id":"team-1","name":"Seniors 1"},'
          '"roles":["OWNER_MANAGER"],'
          '"permissions":["VIEW_ROSTER","MANAGE_ROSTER","INVITE_PLAYER"]}',
          201,
        );
      }),
    );

    final team = await gateway.createClubWithTeam(
      clubName: 'Mon Club',
      teamName: 'Seniors 1',
    );

    expect(team.name, 'Seniors 1');
    expect(team.clubName, 'Mon Club');
  });

  test('creates a coach invitation', () async {
    final gateway = HttpTeamGateway(
      baseUrl: 'https://api.example.com',
      idTokenProvider: () async => 'valid-token',
      client: MockClient((request) async {
        expect(
          request.url.toString(),
          'https://api.example.com/teams/team-1/member-invitations',
        );
        expect(request.method, 'POST');
        expect(request.body, '{"role":"COACH"}');
        return http.Response(
          '{"token":"opaque-team-token","role":"COACH",'
          '"expiresAt":"2026-09-22T12:00:00.000Z"}',
          201,
        );
      }),
    );

    final invitation = await gateway.createMemberInvitation(
      teamId: 'team-1',
      role: TeamInvitationRole.coach,
    );

    expect(invitation.token, 'opaque-team-token');
    expect(invitation.role, TeamInvitationRole.coach);
  });

  test('claims a team member invitation', () async {
    final gateway = HttpTeamGateway(
      baseUrl: 'https://api.example.com',
      idTokenProvider: () async => 'valid-token',
      client: MockClient((request) async {
        expect(
          request.url.toString(),
          'https://api.example.com/team-member-invitations/claim',
        );
        expect(request.method, 'POST');
        expect(request.body, '{"token":"opaque-team-token"}');
        return http.Response(
          '{"id":"team-1","name":"Seniors 1",'
          '"club":{"id":"club-1","name":"Mon Club"},'
          '"roles":["COACH"],'
          '"permissions":["VIEW_ROSTER","MANAGE_ROSTER"]}',
          200,
        );
      }),
    );

    final team = await gateway.claimMemberInvitation('opaque-team-token');

    expect(team.name, 'Seniors 1');
    expect(team.roles, ['COACH']);
  });

  test('rejects an unsuccessful response', () async {
    final gateway = HttpTeamGateway(
      baseUrl: 'https://api.example.com',
      idTokenProvider: () async => 'valid-token',
      client: MockClient((_) async => http.Response('{}', 500)),
    );

    await expectLater(
      gateway.getMyTeams(),
      throwsA(isA<TeamRequestException>()),
    );
  });
}
