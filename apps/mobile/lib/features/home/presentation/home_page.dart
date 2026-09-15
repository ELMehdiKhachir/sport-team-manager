import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sport_team_manager/core/auth/auth_gateway.dart';
import 'package:sport_team_manager/core/network/identity_gateway.dart';
import 'package:sport_team_manager/core/network/player_gateway.dart';
import 'package:sport_team_manager/core/network/team_gateway.dart';
import 'package:sport_team_manager/features/team/presentation/roster_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    required this.user,
    required this.identityGateway,
    required this.teamGateway,
    required this.playerGateway,
    required this.onSignOut,
    super.key,
  });

  final AuthUser user;
  final IdentityGateway identityGateway;
  final TeamGateway teamGateway;
  final PlayerGateway playerGateway;
  final Future<void> Function() onSignOut;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<_HomeData> _homeRequest;
  String? _pendingInviteToken;
  String? _pendingTeamInviteToken;
  String? _selectedTeamId;

  @override
  void initState() {
    super.initState();
    _pendingInviteToken = Uri.base.queryParameters['invite']?.trim();
    if (_pendingInviteToken?.isEmpty == true) _pendingInviteToken = null;
    _pendingTeamInviteToken = Uri.base.queryParameters['teamInvite']?.trim();
    if (_pendingTeamInviteToken?.isEmpty == true) {
      _pendingTeamInviteToken = null;
    }
    _reload();
  }

  void _reload() {
    _homeRequest = _loadHome();
  }

  Future<_HomeData> _loadHome() async {
    final identity = await widget.identityGateway.getCurrentIdentity();
    final teams = await widget.teamGateway.getMyTeams();
    return _HomeData(identity: identity, teams: teams);
  }

  void _retry() {
    setState(_reload);
  }

  Future<void> _claimInvite() async {
    final token = _pendingInviteToken;
    if (token == null) return;
    try {
      final player = await widget.playerGateway.claimInvitation(token);
      if (!mounted) return;
      setState(() {
        _pendingInviteToken = null;
        _reload();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Profil ${player.displayName} associé. Tu as rejoint l’équipe.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Invitation invalide, expirée ou déjà utilisée. Demande un nouveau lien au manager.',
          ),
        ),
      );
    }
  }

  Future<void> _claimTeamInvite() async {
    final token = _pendingTeamInviteToken;
    if (token == null) return;
    try {
      final team = await widget.teamGateway.claimMemberInvitation(token);
      if (!mounted) return;
      setState(() {
        _pendingTeamInviteToken = null;
        _selectedTeamId = team.id;
        _reload();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tu as rejoint ${team.name} avec le rôle ${_rolesLabel(team.roles)}.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Invitation invalide, expirée ou déjà utilisée. Demande un nouveau lien au manager.',
          ),
        ),
      );
    }
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
              'Ton compte est connecté. Préparons maintenant ton équipe.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            FutureBuilder<_HomeData>(
              future: _homeRequest,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Card(
                    child: ListTile(
                      leading: CircularProgressIndicator(),
                      title: Text('Chargement de ton espace'),
                      subtitle: Text('Connexion sécurisée à l’équipe…'),
                    ),
                  );
                }

                final data = snapshot.data;
                final isVerified = data?.identity.firebaseUid == widget.user.id;
                if (snapshot.hasError || !isVerified) {
                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.error_outline, color: colors.error),
                      title: const Text('API temporairement indisponible'),
                      subtitle: const Text(
                        'Impossible de charger ton espace pour le moment.',
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
                        leading:
                            Icon(Icons.verified_user, color: colors.primary),
                        title: const Text('Connexion sécurisée validée'),
                        subtitle: const Text(
                          'Ton identité a été vérifiée par le serveur.',
                        ),
                      ),
                    ),
                    if (_pendingInviteToken != null ||
                        _pendingTeamInviteToken != null) ...[
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Icon(
                                Icons.link_rounded,
                                color: colors.primary,
                                size: 32,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _pendingTeamInviteToken != null
                                    ? 'Invitation dans une équipe'
                                    : 'Invitation reçue',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _pendingTeamInviteToken != null
                                    ? 'Ce lien permet de rejoindre l’équipe comme coach ou membre du staff.'
                                    : 'Ce lien permet de rattacher ton compte au profil joueur préparé par ton équipe.',
                              ),
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                onPressed: _pendingTeamInviteToken != null
                                    ? _claimTeamInvite
                                    : _claimInvite,
                                icon: const Icon(Icons.group_add),
                                label: const Text('Rejoindre mon équipe'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    if (data!.teams.isEmpty)
                      _CreateClubCard(
                        teamGateway: widget.teamGateway,
                        onCreated: _retry,
                      )
                    else
                      _TeamWorkspace(
                        teams: data.teams,
                        selectedTeamId: _selectedTeamId,
                        teamGateway: widget.teamGateway,
                        playerGateway: widget.playerGateway,
                        onTeamSelected: (teamId) {
                          setState(() => _selectedTeamId = teamId);
                        },
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

class _CreateClubCard extends StatefulWidget {
  const _CreateClubCard({
    required this.teamGateway,
    required this.onCreated,
  });

  final TeamGateway teamGateway;
  final VoidCallback onCreated;

  @override
  State<_CreateClubCard> createState() => _CreateClubCardState();
}

class _CreateClubCardState extends State<_CreateClubCard> {
  final _formKey = GlobalKey<FormState>();
  final _clubController = TextEditingController();
  final _teamController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _clubController.dispose();
    _teamController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      await widget.teamGateway.createClubWithTeam(
        clubName: _clubController.text,
        teamName: _teamController.text,
      );
      widget.onCreated();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _error = 'La création a échoué. Réessaie dans un instant.';
      });
    }
  }

  String? _required(String? value) =>
      value?.trim().isEmpty ?? true ? 'Ce champ est obligatoire.' : null;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.groups_rounded, color: colors.primary, size: 32),
              const SizedBox(height: 12),
              Text(
                'Crée ton espace équipe',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tu seras manager de cette équipe. Le rôle coach pourra être ajouté séparément.',
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _clubController,
                enabled: !_isSubmitting,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nom du club',
                  prefixIcon: Icon(Icons.shield_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: _required,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _teamController,
                enabled: !_isSubmitting,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nom de l’équipe',
                  hintText: 'Ex. Seniors 1',
                  prefixIcon: Icon(Icons.sports_soccer),
                  border: OutlineInputBorder(),
                ),
                validator: _required,
                onFieldSubmitted: (_) => _submit(),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: colors.error)),
              ],
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add),
                label: Text(
                  _isSubmitting ? 'Création en cours…' : 'Créer mon équipe',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamWorkspace extends StatelessWidget {
  const _TeamWorkspace({
    required this.teams,
    required this.selectedTeamId,
    required this.teamGateway,
    required this.playerGateway,
    required this.onTeamSelected,
  });

  final List<TeamSummary> teams;
  final String? selectedTeamId;
  final TeamGateway teamGateway;
  final PlayerGateway playerGateway;
  final ValueChanged<String> onTeamSelected;

  TeamSummary get activeTeam => teams.firstWhere(
        (team) => team.id == selectedTeamId,
        orElse: () => teams.first,
      );

  @override
  Widget build(BuildContext context) {
    final team = activeTeam;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (teams.length > 1) ...[
          DropdownButtonFormField<String>(
            key: const Key('active-team-selector'),
            initialValue: team.id,
            decoration: const InputDecoration(
              labelText: 'Équipe active',
              prefixIcon: Icon(Icons.swap_horiz_rounded),
              border: OutlineInputBorder(),
            ),
            items: teams
                .map(
                  (item) => DropdownMenuItem(
                    value: item.id,
                    child: Text(
                      item.clubName == null
                          ? item.name
                          : '${item.clubName} · ${item.name}',
                    ),
                  ),
                )
                .toList(growable: false),
            onChanged: (teamId) {
              if (teamId != null) onTeamSelected(teamId);
            },
          ),
          const SizedBox(height: 12),
        ],
        _TeamCard(
          team: team,
          teamGateway: teamGateway,
          playerGateway: playerGateway,
        ),
      ],
    );
  }
}

class _TeamCard extends StatelessWidget {
  const _TeamCard({
    required this.team,
    required this.teamGateway,
    required this.playerGateway,
  });

  final TeamSummary team;
  final TeamGateway teamGateway;
  final PlayerGateway playerGateway;

  Future<void> _inviteMember(BuildContext context) async {
    final role = await showModalBottomSheet<TeamInvitationRole>(
      context: context,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Inviter dans ${team.name}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            const Text('Choisis le rôle attribué après acceptation du lien.'),
            const SizedBox(height: 16),
            for (final role in TeamInvitationRole.values)
              ListTile(
                leading: Icon(
                  role == TeamInvitationRole.coach
                      ? Icons.sports
                      : Icons.support_agent,
                ),
                title: Text(role.label),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).pop(role),
              ),
          ],
        ),
      ),
    );
    if (role == null || !context.mounted) return;

    try {
      final invitation = await teamGateway.createMemberInvitation(
        teamId: team.id,
        role: role,
      );
      if (!context.mounted) return;
      final parameters = Map<String, String>.from(Uri.base.queryParameters)
        ..remove('invite')
        ..['teamInvite'] = invitation.token;
      final link = Uri.base.replace(queryParameters: parameters).toString();
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('Lien ${role.label} prêt'),
          content: SelectableText(link),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Fermer'),
            ),
            FilledButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: link));
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Lien copié. Tu peux le partager sur WhatsApp.',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copier le lien'),
            ),
          ],
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de créer l’invitation.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
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
                        key: const Key('active-team-name'),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      if (team.clubName != null) Text(team.clubName!),
                      const SizedBox(height: 8),
                      Chip(
                        avatar:
                            const Icon(Icons.admin_panel_settings, size: 18),
                        label: Text(_rolesLabel(team.roles)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => RosterPage(
                    team: team,
                    playerGateway: playerGateway,
                  ),
                ),
              ),
              icon: const Icon(Icons.groups_2_outlined),
              label: const Text('Ouvrir l’effectif'),
            ),
            if (team.allows(TeamPermission.manageTeamMembers)) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => _inviteMember(context),
                icon: const Icon(Icons.person_add_alt),
                label: const Text('Inviter un coach ou un staff'),
              ),
            ],
          ],
        ),
      ),
    );
  }
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

class _HomeData {
  const _HomeData({required this.identity, required this.teams});

  final ServerIdentity identity;
  final List<TeamSummary> teams;
}
