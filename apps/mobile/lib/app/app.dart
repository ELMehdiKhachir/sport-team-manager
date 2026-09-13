import 'package:flutter/material.dart';
import 'package:sport_team_manager/app/theme/app_theme.dart';
import 'package:sport_team_manager/core/auth/auth_gateway.dart';
import 'package:sport_team_manager/core/network/identity_gateway.dart';
import 'package:sport_team_manager/core/network/player_gateway.dart';
import 'package:sport_team_manager/core/network/team_gateway.dart';
import 'package:sport_team_manager/features/auth/presentation/auth_gate.dart';

class SportTeamManagerApp extends StatelessWidget {
  const SportTeamManagerApp({
    required this.authGateway,
    required this.identityGateway,
    required this.teamGateway,
    required this.playerGateway,
    super.key,
  });

  final AuthGateway authGateway;
  final IdentityGateway identityGateway;
  final TeamGateway teamGateway;
  final PlayerGateway playerGateway;

  @override
  Widget build(BuildContext context) {
    const clubPalette = ClubPalette(primary: Color(0xFF145A3A));

    return MaterialApp(
      title: 'Sport Team Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(clubPalette),
      darkTheme: AppTheme.dark(clubPalette),
      themeMode: ThemeMode.system,
      home: AuthGate(
        authGateway: authGateway,
        identityGateway: identityGateway,
        teamGateway: teamGateway,
        playerGateway: playerGateway,
      ),
    );
  }
}
