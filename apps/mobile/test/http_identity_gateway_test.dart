import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sport_team_manager/core/network/http_identity_gateway.dart';

void main() {
  test('sends the Firebase token and decodes the server identity', () async {
    final client = MockClient((request) async {
      expect(request.url.toString(), 'https://api.example.com/identity/me');
      expect(request.headers['Authorization'], 'Bearer valid-token');

      return http.Response(
        '{"firebaseUid":"user-1","email":"coach@example.com",'
        '"displayName":"Mehdi"}',
        200,
      );
    });
    final gateway = HttpIdentityGateway(
      baseUrl: 'https://api.example.com',
      idTokenProvider: () async => 'valid-token',
      client: client,
    );

    final identity = await gateway.getCurrentIdentity();

    expect(identity.firebaseUid, 'user-1');
    expect(identity.email, 'coach@example.com');
    expect(identity.displayName, 'Mehdi');
  });

  test('rejects a response that is not successful', () async {
    final gateway = HttpIdentityGateway(
      baseUrl: 'https://api.example.com',
      idTokenProvider: () async => 'expired-token',
      client: MockClient((_) async => http.Response('{}', 401)),
    );

    await expectLater(
      gateway.getCurrentIdentity(),
      throwsA(isA<IdentityRequestException>()),
    );
  });

  test('does not call the API when no Firebase token is available', () async {
    var requestWasSent = false;
    final gateway = HttpIdentityGateway(
      baseUrl: 'https://api.example.com',
      idTokenProvider: () async => null,
      client: MockClient((_) async {
        requestWasSent = true;
        return http.Response('{}', 200);
      }),
    );

    await expectLater(
      gateway.getCurrentIdentity(),
      throwsA(isA<IdentityRequestException>()),
    );
    expect(requestWasSent, isFalse);
  });
}
