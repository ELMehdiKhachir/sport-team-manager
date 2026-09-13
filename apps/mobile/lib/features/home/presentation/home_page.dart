import 'package:flutter/material.dart';
import 'package:sport_team_manager/core/auth/auth_gateway.dart';
import 'package:sport_team_manager/core/network/identity_gateway.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    required this.user,
    required this.identityGateway,
    required this.onSignOut,
    super.key,
  });

  final AuthUser user;
  final IdentityGateway identityGateway;
  final Future<void> Function() onSignOut;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<ServerIdentity> _identityRequest;

  @override
  void initState() {
    super.initState();
    _identityRequest = widget.identityGateway.getCurrentIdentity();
  }

  void _retryIdentityCheck() {
    setState(() {
      _identityRequest = widget.identityGateway.getCurrentIdentity();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final identity = widget.user.displayName?.trim().isNotEmpty == true
        ? widget.user.displayName!.trim()
        : widget.user.email ?? 'Coach';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sport Team Manager'),
        actions: [
          IconButton(
            tooltip: 'Se déconnecter',
            onPressed: widget.onSignOut,
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
              FutureBuilder<ServerIdentity>(
                future: _identityRequest,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Card(
                      child: ListTile(
                        leading: CircularProgressIndicator(),
                        title: Text('Connexion sécurisée à l’API'),
                        subtitle: Text('Vérification de ton identité…'),
                      ),
                    );
                  }

                  final serverIdentity = snapshot.data;
                  final isVerified =
                      serverIdentity?.firebaseUid == widget.user.id;

                  if (snapshot.hasError || !isVerified) {
                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.error_outline, color: colors.error),
                        title: const Text('API temporairement indisponible'),
                        subtitle: const Text(
                          'Impossible de vérifier ton identité pour le moment.',
                        ),
                        trailing: IconButton(
                          tooltip: 'Réessayer',
                          onPressed: _retryIdentityCheck,
                          icon: const Icon(Icons.refresh),
                        ),
                      ),
                    );
                  }

                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.verified_user, color: colors.primary),
                      title: const Text('Connexion sécurisée validée'),
                      subtitle: const Text(
                        'Ton identité a été vérifiée par le serveur.',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
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
