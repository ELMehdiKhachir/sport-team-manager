import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sport_team_manager/core/network/player_gateway.dart';

class HttpPlayerGateway implements PlayerGateway {
  HttpPlayerGateway({
    required String baseUrl,
    required Future<String?> Function() idTokenProvider,
    http.Client? client,
  })  : _baseUri = Uri.parse(baseUrl),
        _idTokenProvider = idTokenProvider,
        _client = client ?? http.Client();

  final Uri _baseUri;
  final Future<String?> Function() _idTokenProvider;
  final http.Client _client;

  @override
  Future<List<PlayerSummary>> listPlayers(String teamId) async {
    final response = await _client.get(
      _baseUri.resolve('/teams/$teamId/players'),
      headers: await _headers(),
    );
    final payload = _decode(response);
    if (payload is! List) {
      throw const PlayerRequestException('Réponse inattendue de l’API.');
    }
    return payload.map(_fromPayload).toList(growable: false);
  }

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
    final response = await _client.post(
      _baseUri.resolve('/teams/$teamId/players'),
      headers: await _headers(includeJson: true),
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'primaryPosition': primaryPosition.apiValue,
        if (secondaryPosition != null)
          'secondaryPosition': secondaryPosition.apiValue,
        if (shirtNumber != null) 'shirtNumber': shirtNumber,
        if (dominantFoot != null) 'dominantFoot': dominantFoot.apiValue,
      }),
    );
    return _fromPayload(_decode(response));
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
    final response = await _client.patch(
      _baseUri.resolve('/teams/$teamId/players/$playerId'),
      headers: await _headers(includeJson: true),
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'primaryPosition': primaryPosition.apiValue,
        'secondaryPosition': secondaryPosition?.apiValue,
        'shirtNumber': shirtNumber,
        'dominantFoot': dominantFoot?.apiValue,
        if (active != null) 'active': active,
      }),
    );
    return _fromPayload(_decode(response));
  }

  @override
  Future<PlayerInvitation> createInvitation({
    required String teamId,
    required String playerId,
  }) async {
    final response = await _client.post(
      _baseUri.resolve('/teams/$teamId/players/$playerId/invitation'),
      headers: await _headers(),
    );
    final payload = _decode(response);
    if (payload is! Map<String, dynamic> ||
        payload['token'] is! String ||
        payload['expiresAt'] is! String) {
      throw const PlayerRequestException('Réponse inattendue de l’API.');
    }
    return PlayerInvitation(
      token: payload['token'] as String,
      expiresAt: DateTime.parse(payload['expiresAt'] as String),
    );
  }

  @override
  Future<PlayerSummary> claimInvitation(String token) async {
    final response = await _client.post(
      _baseUri.resolve('/player-invitations/claim'),
      headers: await _headers(includeJson: true),
      body: jsonEncode({'token': token}),
    );
    return _fromPayload(_decode(response));
  }

  Future<Map<String, String>> _headers({bool includeJson = false}) async {
    final token = await _idTokenProvider();
    if (token == null || token.isEmpty) {
      throw const PlayerRequestException('Aucun jeton Firebase disponible.');
    }
    return {
      'Authorization': 'Bearer $token',
      if (includeJson) 'Content-Type': 'application/json',
    };
  }

  dynamic _decode(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw PlayerRequestException(
        'L’API a refusé la demande (${response.statusCode}).',
      );
    }
    return jsonDecode(response.body);
  }

  PlayerSummary _fromPayload(dynamic value) {
    if (value is! Map<String, dynamic> ||
        value['id'] is! String ||
        value['teamId'] is! String ||
        value['firstName'] is! String ||
        value['lastName'] is! String ||
        value['primaryPosition'] is! String ||
        value['accountAssociated'] is! bool) {
      throw const PlayerRequestException('Réponse inattendue de l’API.');
    }
    return PlayerSummary(
      id: value['id'] as String,
      teamId: value['teamId'] as String,
      firstName: value['firstName'] as String,
      lastName: value['lastName'] as String,
      primaryPosition:
          PlayerPosition.fromApi(value['primaryPosition'] as String),
      secondaryPosition: value['secondaryPosition'] is String
          ? PlayerPosition.fromApi(value['secondaryPosition'] as String)
          : null,
      shirtNumber: value['shirtNumber'] as int?,
      dominantFoot: value['dominantFoot'] is String
          ? DominantFoot.fromApi(value['dominantFoot'] as String)
          : null,
      active: value['active'] as bool? ?? true,
      accountAssociated: value['accountAssociated'] as bool,
    );
  }
}

class PlayerRequestException implements Exception {
  const PlayerRequestException(this.message);

  final String message;

  @override
  String toString() => message;
}
