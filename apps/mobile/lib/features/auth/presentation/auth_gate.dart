import 'package:flutter/material.dart';
import 'package:sport_team_manager/core/auth/auth_gateway.dart';
import 'package:sport_team_manager/features/auth/presentation/auth_page.dart';
import 'package:sport_team_manager/features/home/presentation/home_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({required this.authGateway, super.key});

  final AuthGateway authGateway;

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

        return HomePage(
          user: user,
          onSignOut: authGateway.signOut,
        );
      },
    );
  }
}
