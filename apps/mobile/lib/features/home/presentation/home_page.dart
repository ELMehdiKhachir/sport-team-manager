import 'package:flutter/material.dart';
import 'package:sport_team_manager/core/auth/auth_gateway.dart';
import 'package:sport_team_manager/core/network/identity_gateway.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    required this.user,
    required this.identityGateway,
    super.key,
  });

  final AuthUser user;
  final IdentityGateway identityGateway;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<ServerIdentity> _identityRequest;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _identityRequest = widget.identityGateway.getCurrentIdentity();
  }

  void _retry() {
    setState(_reload);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final identity = widget.user.displayName?.trim().isNotEmpty == true
        ? widget.user.displayName!.trim()
        : widget.user.email ?? 'Coach';

    return Scaffold(
      key: const Key('home-page'),
      appBar: AppBar(title: const Text('Accueil')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Bonjour $identity !',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Retrouve ici les prochaines échéances et les actions qui demanderont ton attention.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            FutureBuilder<ServerIdentity>(
              future: _identityRequest,
              builder: (context, snapshot) {
                final isVerified =
                    snapshot.data?.firebaseUid == widget.user.id;
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Card(
                    child: ListTile(
                      leading: CircularProgressIndicator(),
                      title: Text('Chargement de ton tableau de bord'),
                    ),
                  );
                }
                if (snapshot.hasError || !isVerified) {
                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.error_outline, color: colors.error),
                      title: const Text('API temporairement indisponible'),
                      subtitle: const Text(
                        'Impossible de charger ton tableau de bord pour le moment.',
                      ),
                      trailing: IconButton(
                        tooltip: 'Réessayer',
                        onPressed: _retry,
                        icon: const Icon(Icons.refresh),
                      ),
                    ),
                  );
                }
                return Column(
                  children: [
                    Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.task_alt_rounded,
                          color: colors.primary,
                        ),
                        title: const Text('Aucune action à traiter'),
                        subtitle: const Text(
                          'Les disponibilités et convocations apparaîtront ici lorsqu’elles seront disponibles.',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.event_outlined,
                          color: colors.primary,
                        ),
                        title: const Text('Prochaines échéances'),
                        subtitle: const Text(
                          'Les prochains matchs et entraînements apparaîtront ici après la mise en place du calendrier.',
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
