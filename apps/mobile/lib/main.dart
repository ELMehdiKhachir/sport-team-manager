import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sport_team_manager/app/app.dart';
import 'package:sport_team_manager/app/config/app_config.dart';
import 'package:sport_team_manager/core/auth/firebase_auth_gateway.dart';
import 'package:sport_team_manager/core/network/http_identity_gateway.dart';
import 'package:sport_team_manager/core/network/http_team_gateway.dart';
import 'package:sport_team_manager/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final authGateway = FirebaseAuthGateway();
  final identityGateway = HttpIdentityGateway(
    baseUrl: AppConfig.apiBaseUrl,
    idTokenProvider: authGateway.getIdToken,
  );
  final teamGateway = HttpTeamGateway(
    baseUrl: AppConfig.apiBaseUrl,
    idTokenProvider: authGateway.getIdToken,
  );

  runApp(
    SportTeamManagerApp(
      authGateway: authGateway,
      identityGateway: identityGateway,
      teamGateway: teamGateway,
    ),
  );
}
