import 'package:flutter/material.dart';
import 'package:sport_team_manager/core/auth/auth_gateway.dart';
import 'package:sport_team_manager/core/network/calendar_gateway.dart';
import 'package:sport_team_manager/core/network/identity_gateway.dart';
import 'package:sport_team_manager/core/network/player_gateway.dart';
import 'package:sport_team_manager/core/network/team_gateway.dart';
import 'package:sport_team_manager/features/auth/presentation/auth_page.dart';
import 'package:sport_team_manager/features/shell/presentation/app_shell.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({
    required this.authGateway,
    required this.identityGateway,
    required this.teamGateway,
    required this.playerGateway,
    required this.calendarGateway,
    super.key,
  });

  final AuthGateway authGateway;
  final IdentityGateway identityGateway;
  final TeamGateway teamGateway;
  final PlayerGateway playerGateway;
  final CalendarGateway calendarGateway;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthUser?>(
      stream: authGateway.userChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) return AuthPage(authGateway: authGateway);

        return AppShell(
          user: user,
          identityGateway: identityGateway,
          teamGateway: teamGateway,
          playerGateway: playerGateway,
          calendarGateway: calendarGateway,
          onSignOut: authGateway.signOut,
        );
      },
    );
  }
}
