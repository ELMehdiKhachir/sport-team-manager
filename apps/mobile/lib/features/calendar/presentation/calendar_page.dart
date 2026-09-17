import 'package:flutter/material.dart';
import 'package:sport_team_manager/core/network/calendar_gateway.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({
    required this.gateway,
    required this.teamId,
    super.key,
  });

  final CalendarGateway gateway;
  final String? teamId;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  Future<List<OfficialMatchSummary>>? _matches;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void didUpdateWidget(CalendarPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.teamId != widget.teamId) _reload();
  }

  void _reload() {
    final teamId = widget.teamId;
    _matches = teamId == null ? null : widget.gateway.getOfficialMatches(teamId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendrier')),
      body: SafeArea(child: _body()),
    );
  }

  Widget _body() {
    if (widget.teamId == null) {
      return const _CalendarMessage(
        icon: Icons.groups_2_outlined,
        title: 'Aucune équipe sélectionnée',
        message: 'Sélectionne une équipe depuis l’onglet Équipe.',
      );
    }
    return FutureBuilder<List<OfficialMatchSummary>>(
      future: _matches,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _CalendarMessage(
            icon: Icons.cloud_off_outlined,
            title: 'Calendrier indisponible',
            message: snapshot.error.toString(),
            action: TextButton.icon(
              onPressed: () => setState(_reload),
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          );
        }
        final matches = snapshot.data ?? const [];
        if (matches.isEmpty) {
          return const _CalendarMessage(
            icon: Icons.calendar_month_outlined,
            title: 'Aucun match officiel',
            message: 'Aucun match FFF synchronisé pour cette équipe.',
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            setState(_reload);
            await _matches;
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: matches.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _MatchCard(match: matches[index]),
          ),
        );
      },
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.match});
  final OfficialMatchSummary match;

  @override
  Widget build(BuildContext context) {
    final local = match.startsAt.toLocal();
    final date = '${_two(local.day)}/${_two(local.month)}/${local.year}';
    final time = '${_two(local.hour)}:${_two(local.minute)}';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('FFF', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(match.competitionName, style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('$date · $time', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Text(match.homeTeamName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Text('vs'),
            ),
            Text(match.awayTeamName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
}

class _CalendarMessage extends StatelessWidget {
  const _CalendarMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 12), action!],
          ],
        ),
      ),
    );
  }
}
