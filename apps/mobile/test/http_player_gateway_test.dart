import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sport_team_manager/core/network/http_player_gateway.dart';
import 'package:sport_team_manager/core/network/player_gateway.dart';

void main() {
  test('lists players of a team', () async {
    final gateway = HttpPlayerGateway(
      baseUrl: 'https://api.example.com',
      idTokenProvider: () async => 'valid-token',
      client: MockClient((request) async {
        expect(request.url.toString(), 'https://api.example.com/teams/team-1/players');
        expect(request.headers['Authorization'], 'Bearer valid-token');
        return http.Response(
          '[{"id":"player-1","teamId":"team-1","firstName":"Amine",'
          '"lastName":"Benali","primaryPosition":"PIVOT",'
          '"secondaryPosition":null,"shirtNumber":10,"dominantFoot":"RIGHT",'
          '"accountAssociated":false}]',
          200,
        );
      }),
    );

    final players = await gateway.listPlayers('team-1');

    expect(players.single.displayName, 'Amine Benali');
    expect(players.single.primaryPosition, PlayerPosition.pivot);
    expect(players.single.accountAssociated, isFalse);
  });

  test('pre-creates a player', () async {
    final gateway = HttpPlayerGateway(
      baseUrl: 'https://api.example.com',
      idTokenProvider: () async => 'valid-token',
      client: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.headers['Authorization'], 'Bearer valid-token');
        expect(request.body, contains('"primaryPosition":"WINGER"'));
        return http.Response(
          '{"id":"player-2","teamId":"team-1","firstName":"Yanis",'
          '"lastName":"Kaci","primaryPosition":"WINGER",'
          '"secondaryPosition":null,"shirtNumber":7,"dominantFoot":null,'
          '"accountAssociated":false}',
          201,
        );
      }),
    );

    final player = await gateway.createPlayer(
      teamId: 'team-1',
      firstName: 'Yanis',
      lastName: 'Kaci',
      primaryPosition: PlayerPosition.winger,
      shirtNumber: 7,
    );

    expect(player.shirtNumber, 7);
    expect(player.accountAssociated, isFalse);
  });
}
