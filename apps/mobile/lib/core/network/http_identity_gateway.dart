import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sport_team_manager/core/network/identity_gateway.dart';

class HttpIdentityGateway implements IdentityGateway {
  HttpIdentityGateway({
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
  Future<ServerIdentity> getCurrentIdentity() async {
    final token = await _idTokenProvider();
    if (token == null || token.isEmpty) {
      throw const IdentityRequestException('Aucun jeton Firebase disponible.');
    }

    final response = await _client.get(
      _baseUri.resolve('/identity/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw IdentityRequestException(
        'L’API a refusé la vérification (${response.statusCode}).',
      );
    }

    final payload = jsonDecode(response.body);
    if (payload is! Map<String, dynamic> || payload['firebaseUid'] is! String) {
      throw const IdentityRequestException('Réponse inattendue de l’API.');
    }

    return ServerIdentity(
      firebaseUid: payload['firebaseUid'] as String,
      email: payload['email'] as String?,
      displayName: payload['displayName'] as String?,
    );
  }
}

class IdentityRequestException implements Exception {
  const IdentityRequestException(this.message);

  final String message;

  @override
  String toString() => message;
}
