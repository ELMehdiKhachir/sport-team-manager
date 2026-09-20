import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sport_team_manager/core/network/calendar_gateway.dart';
import 'package:sport_team_manager/core/network/http_calendar_gateway.dart';

void main() {
  test('lists persisted official matches', () async {
    final gateway = HttpCalendarGateway(
      baseUrl: 'https://api.example.com',
      idTokenProvider: () async => 'valid-token',
      client: MockClient((request) async {
        expect(
          request.url.toString(),
          'https://api.example.com/teams/team-1/calendar/official-matches',
        );
        expect(request.headers['Authorization'], 'Bearer valid-token');
        return http.Response(
          '[{"id":"match-1","provider":"FFF",'
          '"startsAt":"2026-10-03T17:00:00.000Z","venue":"HOME",'
          '"status":"SCHEDULED","homeTeamName":"Nantes",'
          '"awayTeamName":"Pessac","competition":'
          '{"name":"D2 FUTSAL","seasonLabel":"2026-2027"}}]',
          200,
        );
      }),
    );

    final matches = await gateway.getOfficialMatches('team-1');

    expect(matches.single.provider, 'FFF');
    expect(matches.single.venue, 'HOME');
    expect(matches.single.competitionName, 'D2 FUTSAL');
  });

  test('configures distinct official club and team identifiers', () async {
    final gateway = HttpCalendarGateway(
      baseUrl: 'https://api.example.com',
      idTokenProvider: () async => 'valid-token',
      client: MockClient((request) async {
        expect(request.method, 'PUT');
        expect(
          request.url.toString(),
          'https://api.example.com/teams/team-1/calendar/official-matches/link',
        );
        expect(jsonDecode(request.body), {
          'externalClubId': 'club-42',
          'externalTeamId': 'team-7',
          'externalCompetitionId': 'competition-3',
          'competitionName': 'D2 FUTSAL',
          'seasonLabel': '2026-2027',
        });
        return http.Response('{}', 200);
      }),
    );

    await gateway.configureOfficialTeamLink(
      'team-1',
      const OfficialTeamLinkInput(
        externalClubId: 'club-42',
        externalTeamId: 'team-7',
        externalCompetitionId: 'competition-3',
        competitionName: 'D2 FUTSAL',
        seasonLabel: '2026-2027',
      ),
    );
  });

  test('returns the number of synchronized matches', () async {
    final gateway = HttpCalendarGateway(
      baseUrl: 'https://api.example.com',
      idTokenProvider: () async => 'valid-token',
      client: MockClient((request) async {
        expect(request.method, 'POST');
        return http.Response('{"importedMatches":4}', 200);
      }),
    );

    expect(await gateway.syncOfficialMatches('team-1'), 4);
  });
}
