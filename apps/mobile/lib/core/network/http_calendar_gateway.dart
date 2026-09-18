import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sport_team_manager/core/network/calendar_gateway.dart';

class HttpCalendarGateway implements CalendarGateway {
  HttpCalendarGateway({
    required String baseUrl,
    required Future<String?> Function() idTokenProvider,
    http.Client? client,
  })  : _baseUri = Uri.parse(baseUrl),
        _idTokenProvider = idTokenProvider,
        _client = client ?? http.Client();

  final Uri _baseUri;
  final Future<String?> Function() _idTokenProvider;
  final http.Client _client;

  Future<String> _token() async {
    final token = await _idTokenProvider();
    if (token == null || token.isEmpty) {
      throw const CalendarRequestException('Aucun jeton Firebase disponible.');
    }
    return token;
  }

  @override
  Future<List<OfficialMatchSummary>> getOfficialMatches(String teamId) async {
    final token = await _token();
    final response = await _client.get(
      _baseUri.resolve('/teams/$teamId/calendar/official-matches'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw CalendarRequestException(
        'Impossible de charger le calendrier (${response.statusCode}).',
      );
    }
    final payload = jsonDecode(response.body);
    if (payload is! List) {
      throw const CalendarRequestException('Réponse inattendue de l’API.');
    }
    return payload.map((value) {
      if (value is! Map) {
        throw const CalendarRequestException('Réponse inattendue de l’API.');
      }
      final item = Map<String, dynamic>.from(value);
      final competitionValue = item['competition'];
      if (competitionValue is! Map) {
        throw const CalendarRequestException('Compétition officielle manquante.');
      }
      final competition = Map<String, dynamic>.from(competitionValue);
      return OfficialMatchSummary(
        id: item['id'] as String,
        provider: item['provider'] as String,
        startsAt: DateTime.parse(item['startsAt'] as String),
        venue: item['venue'] as String,
        status: item['status'] as String,
        homeTeamName: item['homeTeamName'] as String,
        awayTeamName: item['awayTeamName'] as String,
        competitionName: competition['name'] as String,
        seasonLabel: competition['seasonLabel'] as String?,
      );
    }).toList(growable: false);
  }

  @override
  Future<void> configureOfficialTeamLink(
    String teamId,
    OfficialTeamLinkInput link,
  ) async {
    final token = await _token();
    final response = await _client.put(
      _baseUri.resolve('/teams/$teamId/calendar/official-matches/link'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'externalClubId': link.externalClubId,
        if (link.externalTeamId != null) 'externalTeamId': link.externalTeamId,
        'externalCompetitionId': link.externalCompetitionId,
        'competitionName': link.competitionName,
        if (link.seasonLabel != null) 'seasonLabel': link.seasonLabel,
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw CalendarRequestException(
        'Impossible d’enregistrer la liaison FFF (${response.statusCode}).',
      );
    }
  }

  @override
  Future<int> syncOfficialMatches(String teamId) async {
    final token = await _token();
    final response = await _client.post(
      _baseUri.resolve('/teams/$teamId/calendar/official-matches/sync'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw CalendarRequestException(
        'Impossible de synchroniser avec la FFF (${response.statusCode}).',
      );
    }
    final payload = jsonDecode(response.body);
    if (payload is! Map || payload['importedMatches'] is! num) {
      throw const CalendarRequestException(
        'Réponse de synchronisation inattendue.',
      );
    }
    return (payload['importedMatches'] as num).toInt();
  }

}

class CalendarRequestException implements Exception {
  const CalendarRequestException(this.message);
  final String message;
  @override
  String toString() => message;
}
