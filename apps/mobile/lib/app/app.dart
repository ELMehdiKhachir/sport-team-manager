import 'package:flutter/material.dart';
import 'package:sport_team_manager/app/theme/app_theme.dart';
import 'package:sport_team_manager/core/auth/auth_gateway.dart';
import 'package:sport_team_manager/core/network/calendar_gateway.dart';
import 'package:sport_team_manager/core/network/identity_gateway.dart';
import 'package:sport_team_manager/core/network/player_gateway.dart';
import 'package:sport_team_manager/core/network/team_gateway.dart';
import 'package:sport_team_manager/features/auth/presentation/auth_gate.dart';

class SportTeamManagerApp extends StatelessWidget {
  SportTeamManagerApp({
    required this.authGateway,
    required this.identityGateway,
    required this.teamGateway,
    required this.playerGateway,
    CalendarGateway? calendarGateway,
    super.key,
  }) : calendarGateway = calendarGateway ?? const _EmptyCalendarGateway();

  final AuthGateway authGateway;
  final IdentityGateway identityGateway;
  final TeamGateway teamGateway;
  final PlayerGateway playerGateway;
  final CalendarGateway calendarGateway;

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
        calendarGateway: calendarGateway,
      ),
    );
  }
}

class _EmptyCalendarGateway implements CalendarGateway {
  const _EmptyCalendarGateway();

  @override
  Future<List<OfficialMatchSummary>> getOfficialMatches(String teamId) async =>
      const [];
}
