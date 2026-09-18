import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sport_team_manager/core/network/calendar_gateway.dart';
import 'package:sport_team_manager/core/network/player_gateway.dart';
import 'package:sport_team_manager/core/network/team_gateway.dart';
import 'package:sport_team_manager/features/team/presentation/roster_page.dart';

class TeamPage extends StatefulWidget {
  const TeamPage({
    required this.teamGateway,
    required this.playerGateway,
    required this.calendarGateway,
    required this.selectedTeamId,
    required this.onTeamSelected,
    required this.onTeamsChanged,
    super.key,
  });

  final TeamGateway teamGateway;
  final PlayerGateway playerGateway;
  final CalendarGateway calendarGateway;
  final String? selectedTeamId;
  final ValueChanged<String> onTeamSelected;
  final ValueChanged<String?> onTeamsChanged;

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  late Future<List<TeamSummary>> _teamsRequest;
  String? _pendingInviteToken;
  String? _pendingTeamInviteToken;

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
    _teamsRequest = widget.teamGateway.getMyTeams();
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
      widget.onTeamsChanged(player.teamId);
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
        _reload();
      });
      widget.onTeamsChanged(team.id);
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

    return Scaffold(
      key: const Key('team-page'),
      appBar: AppBar(title: const Text('Équipe')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Mon équipe',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Retrouve ici l’effectif, le staff et les actions liées à ton équipe active.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            FutureBuilder<List<TeamSummary>>(
              future: _teamsRequest,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Card(
                    child: ListTile(
                      leading: CircularProgressIndicator(),
                      title: Text('Chargement de l’équipe'),
                      subtitle: Text('Récupération de ton espace…'),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.error_outline, color: colors.error),
                      title: const Text('Équipe temporairement indisponible'),
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
                    if (_pendingInviteToken != null ||
                        _pendingTeamInviteToken != null) ...[
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
                      const SizedBox(height: 12),
                    ],
                    if ((snapshot.data ?? const <TeamSummary>[]).isEmpty)
                      _CreateClubCard(
                        teamGateway: widget.teamGateway,
                        onCreated: (team) {
                          _retry();
                          widget.onTeamsChanged(team.id);
                        },
                      )
                    else
                      _TeamWorkspace(
                        teams: snapshot.data!,
                        selectedTeamId: widget.selectedTeamId,
                        teamGateway: widget.teamGateway,
                        playerGateway: widget.playerGateway,
                        calendarGateway: widget.calendarGateway,
                        onTeamSelected: widget.onTeamSelected,
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
  final ValueChanged<TeamSummary> onCreated;

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
      final team = await widget.teamGateway.createClubWithTeam(
        clubName: _clubController.text,
        teamName: _teamController.text,
      );
      widget.onCreated(team);
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
    required this.calendarGateway,
    required this.onTeamSelected,
  });

  final List<TeamSummary> teams;
  final String? selectedTeamId;
  final TeamGateway teamGateway;
  final PlayerGateway playerGateway;
  final CalendarGateway calendarGateway;
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
          calendarGateway: calendarGateway,
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
    required this.calendarGateway,
  });

  final TeamSummary team;
  final TeamGateway teamGateway;
  final PlayerGateway playerGateway;
  final CalendarGateway calendarGateway;

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

  Future<void> _configureFff(BuildContext context) async {
    final club = TextEditingController();
    final competition = TextEditingController();
    final name = TextEditingController(text: 'D2 FUTSAL');
    final season = TextEditingController(text: '2026-2027');
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Lier l’équipe à la FFF'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: club,
                  decoration:
                      const InputDecoration(labelText: 'ID club FFF/API'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Obligatoire' : null,
                ),
                TextFormField(
                  controller: competition,
                  decoration:
                      const InputDecoration(labelText: 'ID compétition FFF'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Obligatoire' : null,
                ),
                TextFormField(
                  controller: name,
                  decoration:
                      const InputDecoration(labelText: 'Nom compétition'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Obligatoire' : null,
                ),
                TextFormField(
                  controller: season,
                  decoration: const InputDecoration(labelText: 'Saison'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuler')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate())
                Navigator.pop(dialogContext, true);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    if (saved != true || !context.mounted) return;
    try {
      await calendarGateway.configureOfficialTeamLink(
        team.id,
        OfficialTeamLinkInput(
          externalClubId: club.text.trim(),
          externalCompetitionId: competition.text.trim(),
          competitionName: name.text.trim(),
          seasonLabel: season.text.trim().isEmpty ? null : season.text.trim(),
        ),
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Liaison FFF enregistrée.')),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Impossible d’enregistrer la liaison FFF.')),
      );
    } finally {
      club.dispose();
      competition.dispose();
      name.dispose();
      season.dispose();
    }
  }

  Future<void> _syncFff(BuildContext context) async {
    try {
      final imported = await calendarGateway.syncOfficialMatches(team.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$imported match(s) officiel(s) synchronisé(s).')),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Synchronisation FFF impossible. Vérifie d’abord la liaison officielle.'),
        ),
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
            if (team.allows(TeamPermission.fffSync)) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                key: const Key('configure-fff-link'),
                onPressed: () => _configureFff(context),
                icon: const Icon(Icons.link),
                label: const Text('Configurer la liaison FFF'),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                key: const Key('sync-fff'),
                onPressed: () => _syncFff(context),
                icon: const Icon(Icons.sync),
                label: const Text('Synchroniser avec la FFF'),
              ),
            ],
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
