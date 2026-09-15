import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sport_team_manager/core/network/player_gateway.dart';
import 'package:sport_team_manager/core/network/team_gateway.dart';

class RosterPage extends StatefulWidget {
  const RosterPage({
    required this.team,
    required this.playerGateway,
    super.key,
  });

  final TeamSummary team;
  final PlayerGateway playerGateway;

  @override
  State<RosterPage> createState() => _RosterPageState();
}

class _RosterPageState extends State<RosterPage> {
  late Future<List<PlayerSummary>> _players;

  bool get _canManage => widget.team.allows(TeamPermission.manageRoster);

  bool get _canInvite => widget.team.allows(TeamPermission.invitePlayer);

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _players = widget.playerGateway.listPlayers(widget.team.id);
  }

  Future<void> _addPlayer() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _PlayerFormSheet(
        teamId: widget.team.id,
        playerGateway: widget.playerGateway,
      ),
    );
    if (created == true && mounted) {
      setState(_reload);
    }
  }

  Future<void> _editPlayer(PlayerSummary player) async {
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _PlayerFormSheet(
        teamId: widget.team.id,
        playerGateway: widget.playerGateway,
        player: player,
      ),
    );
    if (updated == true && mounted) {
      setState(_reload);
    }
  }

  Future<void> _setActive(PlayerSummary player) async {
    if (player.active) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Désactiver ${player.firstName} ?'),
          content: const Text(
            'Le joueur restera dans l’effectif et pourra être réactivé plus tard.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Désactiver'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    try {
      await widget.playerGateway.updatePlayer(
        teamId: widget.team.id,
        playerId: player.id,
        firstName: player.firstName,
        lastName: player.lastName,
        primaryPosition: player.primaryPosition,
        secondaryPosition: player.secondaryPosition,
        shirtNumber: player.shirtNumber,
        dominantFoot: player.dominantFoot,
        active: !player.active,
      );
      if (mounted) setState(_reload);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            player.active
                ? 'Impossible de désactiver ce joueur.'
                : 'Impossible de réactiver ce joueur.',
          ),
        ),
      );
    }
  }

  Future<void> _invite(PlayerSummary player) async {
    try {
      final invitation = await widget.playerGateway.createInvitation(
        teamId: widget.team.id,
        playerId: player.id,
      );
      if (!mounted) return;
      final link =
          'https://elmehdikhachir.github.io/sport-team-manager/?invite=${Uri.encodeQueryComponent(invitation.token)}';
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Inviter ${player.firstName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Envoie ce lien au joueur. Après connexion, il pourra rattacher ce profil existant à son compte.',
              ),
              const SizedBox(height: 16),
              SelectableText(link),
              const SizedBox(height: 12),
              Text(
                'Lien valable jusqu’au ${MaterialLocalizations.of(context).formatMediumDate(invitation.expiresAt.toLocal())}.',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
            FilledButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: link));
                if (!context.mounted) return;
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de générer l’invitation.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Effectif · ${widget.team.name}')),
      floatingActionButton: _canManage
          ? FloatingActionButton.extended(
              onPressed: _addPlayer,
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Ajouter un joueur'),
            )
          : null,
      body: FutureBuilder<List<PlayerSummary>>(
        future: _players,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _RosterError(onRetry: () => setState(_reload));
          }
          final players = snapshot.data ?? const <PlayerSummary>[];
          if (players.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Aucun joueur dans l’effectif.\nAjoute le premier joueur sans attendre qu’il crée un compte.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: players.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) => _PlayerCard(
              player: players[index],
              canEdit: _canManage,
              canToggleActive: _canManage,
              canInvite: _canInvite &&
                  players[index].active &&
                  !players[index].accountAssociated,
              onEdit: () => _editPlayer(players[index]),
              onToggleActive: () => _setActive(players[index]),
              onInvite: () => _invite(players[index]),
            ),
          );
        },
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({
    required this.player,
    required this.canEdit,
    required this.canToggleActive,
    required this.canInvite,
    required this.onEdit,
    required this.onToggleActive,
    required this.onInvite,
  });

  final PlayerSummary player;
  final bool canEdit;
  final bool canToggleActive;
  final bool canInvite;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final positionLabel =
        '${player.primaryPosition.label}${player.secondaryPosition == null ? '' : ' · ${player.secondaryPosition!.label}'}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              child:
                  Text(player.shirtNumber?.toString() ?? player.firstName[0]),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.displayName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    positionLabel,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        visualDensity: VisualDensity.compact,
                        avatar: Icon(
                          player.active
                              ? Icons.check_circle_outline
                              : Icons.pause_circle_outline,
                          size: 18,
                        ),
                        label: Text(player.active ? 'Actif' : 'Inactif'),
                        side: BorderSide(color: colors.outlineVariant),
                      ),
                      Chip(
                        visualDensity: VisualDensity.compact,
                        avatar: Icon(
                          player.accountAssociated
                              ? Icons.verified_user
                              : Icons.person_outline,
                          size: 18,
                        ),
                        label: Text(
                          player.accountAssociated
                              ? 'Compte associé'
                              : 'Compte non associé',
                        ),
                        side: BorderSide(color: colors.outlineVariant),
                      ),
                      if (canEdit)
                        OutlinedButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Modifier'),
                        ),
                      if (canToggleActive)
                        OutlinedButton.icon(
                          onPressed: onToggleActive,
                          icon: Icon(
                            player.active
                                ? Icons.person_off_outlined
                                : Icons.person_add_alt,
                          ),
                          label: Text(
                            player.active ? 'Désactiver' : 'Réactiver',
                          ),
                        ),
                      if (canInvite)
                        OutlinedButton.icon(
                          onPressed: onInvite,
                          icon: const Icon(Icons.link),
                          label: const Text('Inviter'),
                        ),
                    ],
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

class _RosterError extends StatelessWidget {
  const _RosterError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40),
            const SizedBox(height: 12),
            const Text('Impossible de charger l’effectif.'),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerFormSheet extends StatefulWidget {
  const _PlayerFormSheet({
    required this.teamId,
    required this.playerGateway,
    this.player,
  });

  final String teamId;
  final PlayerGateway playerGateway;
  final PlayerSummary? player;

  @override
  State<_PlayerFormSheet> createState() => _PlayerFormSheetState();
}

class _PlayerFormSheetState extends State<_PlayerFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _shirtNumber;
  PlayerPosition? _primaryPosition;
  PlayerPosition? _secondaryPosition;
  DominantFoot? _dominantFoot;
  bool _submitting = false;
  String? _error;

  bool get _editing => widget.player != null;

  @override
  void initState() {
    super.initState();
    final player = widget.player;
    _firstName = TextEditingController(text: player?.firstName);
    _lastName = TextEditingController(text: player?.lastName);
    _shirtNumber = TextEditingController(text: player?.shirtNumber?.toString());
    _primaryPosition = player?.primaryPosition;
    _secondaryPosition = player?.secondaryPosition;
    _dominantFoot = player?.dominantFoot;
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _shirtNumber.dispose();
    super.dispose();
  }

  String? _required(String? value) =>
      value?.trim().isEmpty ?? true ? 'Ce champ est obligatoire.' : null;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _primaryPosition == null) {
      setState(() {});
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final shirtNumber = _shirtNumber.text.trim().isEmpty
          ? null
          : int.tryParse(_shirtNumber.text.trim());
      if (_editing) {
        await widget.playerGateway.updatePlayer(
          teamId: widget.teamId,
          playerId: widget.player!.id,
          firstName: _firstName.text,
          lastName: _lastName.text,
          primaryPosition: _primaryPosition!,
          secondaryPosition: _secondaryPosition,
          shirtNumber: shirtNumber,
          dominantFoot: _dominantFoot,
        );
      } else {
        await widget.playerGateway.createPlayer(
          teamId: widget.teamId,
          firstName: _firstName.text,
          lastName: _lastName.text,
          primaryPosition: _primaryPosition!,
          secondaryPosition: _secondaryPosition,
          shirtNumber: shirtNumber,
          dominantFoot: _dominantFoot,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = _editing
            ? 'Impossible de modifier ce joueur. Vérifie les informations.'
            : 'Impossible d’ajouter ce joueur. Vérifie les informations.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _editing ? 'Modifier le joueur' : 'Ajouter un joueur',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              _editing
                  ? 'Mets à jour les informations sportives du joueur.'
                  : 'Le joueur n’a pas besoin de compte maintenant. Son profil pourra être associé plus tard.',
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _firstName,
              enabled: !_submitting,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Prénom',
                border: OutlineInputBorder(),
              ),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _lastName,
              enabled: !_submitting,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nom',
                border: OutlineInputBorder(),
              ),
              validator: _required,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<PlayerPosition>(
              initialValue: _primaryPosition,
              decoration: const InputDecoration(
                labelText: 'Poste principal',
                border: OutlineInputBorder(),
              ),
              items: PlayerPosition.values
                  .map(
                    (position) => DropdownMenuItem(
                      value: position,
                      child: Text(position.label),
                    ),
                  )
                  .toList(),
              onChanged: _submitting
                  ? null
                  : (value) => setState(() => _primaryPosition = value),
              validator: (value) =>
                  value == null ? 'Choisis un poste principal.' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<PlayerPosition>(
              initialValue: _secondaryPosition,
              decoration: const InputDecoration(
                labelText: 'Poste secondaire (optionnel)',
                border: OutlineInputBorder(),
              ),
              items: PlayerPosition.values
                  .map(
                    (position) => DropdownMenuItem(
                      value: position,
                      child: Text(position.label),
                    ),
                  )
                  .toList(),
              onChanged: _submitting
                  ? null
                  : (value) => setState(() => _secondaryPosition = value),
            ),
            if (_secondaryPosition != null)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _submitting
                      ? null
                      : () => setState(() => _secondaryPosition = null),
                  child: const Text('Effacer le poste secondaire'),
                ),
              ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _shirtNumber,
              enabled: !_submitting,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Numéro de maillot (optionnel)',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return null;
                final number = int.tryParse(value.trim());
                return number == null || number < 0
                    ? 'Entre un numéro valide.'
                    : null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<DominantFoot>(
              initialValue: _dominantFoot,
              decoration: const InputDecoration(
                labelText: 'Pied fort (optionnel)',
                border: OutlineInputBorder(),
              ),
              items: DominantFoot.values
                  .map(
                    (foot) => DropdownMenuItem(
                      value: foot,
                      child: Text(foot.label),
                    ),
                  )
                  .toList(),
              onChanged: _submitting
                  ? null
                  : (value) => setState(() => _dominantFoot = value),
            ),
            if (_dominantFoot != null)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _submitting
                      ? null
                      : () => setState(() => _dominantFoot = null),
                  child: const Text('Effacer le pied fort'),
                ),
              ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(_editing ? Icons.save : Icons.person_add_alt_1),
              label: Text(
                _submitting
                    ? (_editing ? 'Enregistrement…' : 'Ajout en cours…')
                    : (_editing ? 'Enregistrer' : 'Ajouter le joueur'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
