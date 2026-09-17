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

  @override
  Future<List<OfficialMatchSummary>> getOfficialMatches(String teamId) async {
    final token = await _idTokenProvider();
    if (token == null || token.isEmpty) {
      throw const CalendarRequestException('Aucun jeton Firebase disponible.');
    }
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
}

class CalendarRequestException implements Exception {
  const CalendarRequestException(this.message);
  final String message;
  @override
  String toString() => message;
}
