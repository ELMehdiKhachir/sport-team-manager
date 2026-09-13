import 'package:flutter/material.dart';
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

  bool get _canManage => widget.team.roles.any(
        (role) => role == 'OWNER_MANAGER' || role == 'COACH',
      );

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
      builder: (context) => _AddPlayerSheet(
        teamId: widget.team.id,
        playerGateway: widget.playerGateway,
      ),
    );
    if (created == true && mounted) {
      setState(_reload);
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
            itemBuilder: (context, index) =>
                _PlayerCard(player: players[index]),
          );
        },
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({required this.player});

  final PlayerSummary player;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(player.shirtNumber?.toString() ?? player.firstName[0]),
        ),
        title: Text(player.displayName),
        subtitle: Text(
          '${player.primaryPosition.label}${player.secondaryPosition == null ? '' : ' · ${player.secondaryPosition!.label}'}',
        ),
        trailing: Chip(
          avatar: Icon(
            player.accountAssociated
                ? Icons.verified_user
                : Icons.person_outline,
            size: 18,
          ),
          label: Text(
            player.accountAssociated ? 'Compte associé' : 'Compte non associé',
          ),
          side: BorderSide(color: colors.outlineVariant),
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

class _AddPlayerSheet extends StatefulWidget {
  const _AddPlayerSheet({
    required this.teamId,
    required this.playerGateway,
  });

  final String teamId;
  final PlayerGateway playerGateway;

  @override
  State<_AddPlayerSheet> createState() => _AddPlayerSheetState();
}

class _AddPlayerSheetState extends State<_AddPlayerSheet> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _shirtNumber = TextEditingController();
  PlayerPosition? _primaryPosition;
  PlayerPosition? _secondaryPosition;
  DominantFoot? _dominantFoot;
  bool _submitting = false;
  String? _error;

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
      await widget.playerGateway.createPlayer(
        teamId: widget.teamId,
        firstName: _firstName.text,
        lastName: _lastName.text,
        primaryPosition: _primaryPosition!,
        secondaryPosition: _secondaryPosition,
        shirtNumber: _shirtNumber.text.trim().isEmpty
            ? null
            : int.tryParse(_shirtNumber.text.trim()),
        dominantFoot: _dominantFoot,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = 'Impossible d’ajouter ce joueur. Vérifie les informations.';
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
              'Ajouter un joueur',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Le joueur n’a pas besoin de compte maintenant. Son profil pourra être associé plus tard.',
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
                  : const Icon(Icons.person_add_alt_1),
              label:
                  Text(_submitting ? 'Ajout en cours…' : 'Ajouter le joueur'),
            ),
          ],
        ),
      ),
    );
  }
}
