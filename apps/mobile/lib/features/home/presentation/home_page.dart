import 'package:flutter/material.dart';
import 'package:sport_team_manager/core/auth/auth_gateway.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    required this.user,
    required this.onSignOut,
    super.key,
  });

  final AuthUser user;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final identity = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : user.email ?? 'Coach';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sport Team Manager'),
        actions: [
          IconButton(
            tooltip: 'Se déconnecter',
            onPressed: onSignOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bonjour $identity !',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Ton compte est connecté. Le terrain est prêt pour la suite.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: ListTile(
                  leading: Icon(Icons.sports_soccer, color: colors.primary),
                  title: const Text('Thème du club'),
                  subtitle: const Text(
                    'Clair, sombre et prêt pour des couleurs dynamiques',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
