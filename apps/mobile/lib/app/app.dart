import 'package:flutter/material.dart';
import 'package:sport_team_manager/app/theme/app_theme.dart';
import 'package:sport_team_manager/core/auth/auth_gateway.dart';
import 'package:sport_team_manager/features/auth/presentation/auth_gate.dart';

class SportTeamManagerApp extends StatelessWidget {
  const SportTeamManagerApp({
    required this.authGateway,
    super.key,
  });

  final AuthGateway authGateway;

  @override
  Widget build(BuildContext context) {
    const clubPalette = ClubPalette(primary: Color(0xFF145A3A));

    return MaterialApp(
      title: 'Sport Team Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(clubPalette),
      darkTheme: AppTheme.dark(clubPalette),
      themeMode: ThemeMode.system,
      home: AuthGate(authGateway: authGateway),
    );
  }
}
