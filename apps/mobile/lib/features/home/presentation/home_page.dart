import 'package:flutter/material.dart';
import 'package:sport_team_manager/core/auth/auth_gateway.dart';
import 'package:sport_team_manager/core/network/identity_gateway.dart';
import 'package:sport_team_manager/core/network/team_gateway.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    required this.user,
    required this.identityGateway,
    required this.teamGateway,
    required this.selectedTeamId,
    required this.teamsRevision,
    required this.onOpenTeam,
    super.key,
  });

  final AuthUser user;
  final IdentityGateway identityGateway;
  final TeamGateway teamGateway;
  final String? selectedTeamId;
  final int teamsRevision;
  final VoidCallback onOpenTeam;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<_DashboardData> _dashboardRequest;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.teamsRevision != widget.teamsRevision) _reload();
  }

  void _reload() {
    _dashboardRequest = _loadDashboard();
  }

  Future<_DashboardData> _loadDashboard() async {
    final results = await Future.wait<Object>([
      widget.identityGateway.getCurrentIdentity(),
      widget.teamGateway.getMyTeams(),
    ]);
    return _DashboardData(
      identity: results[0] as ServerIdentity,
      teams: results[1] as List<TeamSummary>,
    );
  }

  void _retry() {
    setState(_reload);
  }

  TeamSummary? _activeTeam(List<TeamSummary> teams) {
    if (teams.isEmpty) return null;
    return teams.firstWhere(
      (team) => team.id == widget.selectedTeamId,
      orElse: () => teams.first,
    );
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
              'Retrouve ici ce qui demande ton attention pour ton équipe active.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            FutureBuilder<_DashboardData>(
              future: _dashboardRequest,
              builder: (context, snapshot) {
                final isVerified =
                    snapshot.data?.identity.firebaseUid == widget.user.id;
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
                      title: const Text('Tableau de bord indisponible'),
                      subtitle: const Text(
                        'Impossible de charger tes informations pour le moment.',
                      ),
                      trailing: IconButton(
                        tooltip: 'Réessayer',
                        onPressed: _retry,
                        icon: const Icon(Icons.refresh),
                      ),
                    ),
                  );
                }

                final team = _activeTeam(snapshot.data!.teams);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (team != null) ...[
                      _TeamContextCard(team: team),
                      const SizedBox(height: 24),
                    ],
                    Text(
                      'Actions prioritaires',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 10),
                    if (team == null)
                      _PriorityCard(
                        icon: Icons.group_add_outlined,
                        title: 'Crée ton espace équipe',
                        message:
                            'Commence par créer ton club et ta première équipe.',
                        buttonKey: const Key('home-create-team'),
                        buttonLabel: 'Ouvrir Équipe',
                        onPressed: widget.onOpenTeam,
                      )
                    else
                      _PriorityCard(
                        icon: Icons.task_alt_rounded,
                        title: 'Aucune action à traiter',
                        message: _priorityMessage(team),
                        buttonKey: const Key('home-open-team'),
                        buttonLabel: 'Ouvrir l’espace Équipe',
                        onPressed: widget.onOpenTeam,
                      ),
                    const SizedBox(height: 24),
                    Text(
                      'Prochaines échéances',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.event_outlined,
                          color: colors.primary,
                        ),
                        title: const Text('Aucune échéance disponible'),
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

class _DashboardData {
  const _DashboardData({required this.identity, required this.teams});

  final ServerIdentity identity;
  final List<TeamSummary> teams;
}

class _TeamContextCard extends StatelessWidget {
  const _TeamContextCard({required this.team});

  final TeamSummary team;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      key: const Key('home-team-context'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: colors.primaryContainer,
              foregroundColor: colors.onPrimaryContainer,
              child: const Icon(Icons.sports_soccer),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    team.name,
                    key: const Key('home-active-team-name'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  if (team.clubName != null) ...[
                    const SizedBox(height: 2),
                    Text(team.clubName!),
                  ],
                  const SizedBox(height: 10),
                  Chip(
                    avatar: const Icon(Icons.badge_outlined, size: 18),
                    label: Text(_rolesLabel(team.roles)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityCard extends StatelessWidget {
  const _PriorityCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.buttonKey,
    required this.buttonLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final Key buttonKey;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(icon, color: colors.primary, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              key: buttonKey,
              onPressed: onPressed,
              icon: const Icon(Icons.arrow_forward),
              label: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}

String _priorityMessage(TeamSummary team) {
  if (team.allows(TeamPermission.manageRoster) ||
      team.allows(TeamPermission.manageTeamMembers)) {
    return 'Ton espace équipe est prêt. Tu peux gérer l’effectif et le staff depuis Équipe.';
  }
  if (team.allows(TeamPermission.respondAvailability)) {
    return 'Aucune disponibilité ne demande ta réponse pour le moment.';
  }
  return 'Aucune action n’est disponible pour le moment.';
}

String _rolesLabel(List<String> roles) => roles
    .map((role) => switch (role) {
          'OWNER_MANAGER' => 'Manager',
          'STAFF_ASSISTANT' => 'Staff',
          'COACH' => 'Coach',
          'PLAYER' => 'Joueur',
          _ => role,
        })
    .join(' · ');
