import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sport_team_manager/core/network/team_gateway.dart';

class HttpTeamGateway implements TeamGateway {
  HttpTeamGateway({
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
  Future<List<TeamSummary>> getMyTeams() async {
    final response = await _client.get(
      _baseUri.resolve('/teams/mine'),
      headers: await _headers(),
    );
    final payload = _decode(response);
    if (payload is! List) {
      throw const TeamRequestException('Réponse inattendue de l’API.');
    }

    return payload.map(_teamFromListPayload).toList(growable: false);
  }

  @override
  Future<TeamSummary> createClubWithTeam({
    required String clubName,
    required String teamName,
  }) async {
    final response = await _client.post(
      _baseUri.resolve('/clubs'),
      headers: await _headers(includeJson: true),
      body: jsonEncode({'clubName': clubName, 'teamName': teamName}),
    );
    final payload = _decode(response);
    if (payload is! Map<String, dynamic> ||
        payload['club'] is! Map ||
        payload['team'] is! Map ||
        payload['roles'] is! List ||
        payload['permissions'] is! List) {
      throw const TeamRequestException('Réponse inattendue de l’API.');
    }

    final club = Map<String, dynamic>.from(payload['club'] as Map);
    final team = Map<String, dynamic>.from(payload['team'] as Map);
    return TeamSummary(
      id: team['id'] as String,
      name: team['name'] as String,
      clubId: club['id'] as String,
      clubName: club['name'] as String,
      roles: List<String>.from(payload['roles'] as List),
      permissions: List<String>.from(payload['permissions'] as List),
    );
  }

  @override
  Future<TeamMemberInvitation> createMemberInvitation({
    required String teamId,
    required TeamInvitationRole role,
  }) async {
    final response = await _client.post(
      _baseUri.resolve('/teams/$teamId/member-invitations'),
      headers: await _headers(includeJson: true),
      body: jsonEncode({'role': role.apiValue}),
    );
    final payload = _decode(response);
    if (payload is! Map<String, dynamic> ||
        payload['token'] is! String ||
        payload['role'] is! String ||
        payload['expiresAt'] is! String) {
      throw const TeamRequestException('Réponse inattendue de l’API.');
    }
    return TeamMemberInvitation(
      token: payload['token'] as String,
      role: TeamInvitationRole.fromApi(payload['role'] as String),
      expiresAt: DateTime.parse(payload['expiresAt'] as String),
    );
  }

  @override
  Future<TeamSummary> claimMemberInvitation(String token) async {
    final response = await _client.post(
      _baseUri.resolve('/team-member-invitations/claim'),
      headers: await _headers(includeJson: true),
      body: jsonEncode({'token': token}),
    );
    return _teamFromListPayload(_decode(response));
  }

  Future<Map<String, String>> _headers({bool includeJson = false}) async {
    final token = await _idTokenProvider();
    if (token == null || token.isEmpty) {
      throw const TeamRequestException('Aucun jeton Firebase disponible.');
    }
    return {
      'Authorization': 'Bearer $token',
      if (includeJson) 'Content-Type': 'application/json',
    };
  }

  dynamic _decode(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw TeamRequestException(
        'L’API a refusé la demande (${response.statusCode}).',
      );
    }
    return jsonDecode(response.body);
  }

  TeamSummary _teamFromListPayload(dynamic value) {
    if (value is! Map<String, dynamic> ||
        value['id'] is! String ||
        value['name'] is! String ||
        value['roles'] is! List ||
        value['permissions'] is! List) {
      throw const TeamRequestException('Réponse inattendue de l’API.');
    }
    final clubValue = value['club'];
    final club = clubValue is Map
        ? Map<String, dynamic>.from(clubValue)
        : <String, dynamic>{};
    return TeamSummary(
      id: value['id'] as String,
      name: value['name'] as String,
      clubId: club['id'] as String?,
      clubName: club['name'] as String?,
      roles: List<String>.from(value['roles'] as List),
      permissions: List<String>.from(value['permissions'] as List),
    );
  }
}

class TeamRequestException implements Exception {
  const TeamRequestException(this.message);

  final String message;

  @override
  String toString() => message;
}
