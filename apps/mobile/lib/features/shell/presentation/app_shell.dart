import 'package:flutter/material.dart';
import 'package:sport_team_manager/core/auth/auth_gateway.dart';
import 'package:sport_team_manager/core/network/identity_gateway.dart';
import 'package:sport_team_manager/core/network/player_gateway.dart';
import 'package:sport_team_manager/core/network/team_gateway.dart';
import 'package:sport_team_manager/features/home/presentation/home_page.dart';
import 'package:sport_team_manager/features/team/presentation/team_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({
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
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _selectedIndex;
  String? _selectedTeamId;
  int _teamsRevision = 0;

  @override
  void initState() {
    super.initState();
    final parameters = Uri.base.queryParameters;
    _selectedIndex =
        parameters.containsKey('invite') || parameters.containsKey('teamInvite')
            ? 2
            : 0;
  }

  void _selectTab(int index) {
    setState(() => _selectedIndex = index);
  }

  void _selectTeam(String teamId) {
    setState(() => _selectedTeamId = teamId);
  }

  void _teamsChanged(String? activeTeamId) {
    setState(() {
      if (activeTeamId != null) _selectedTeamId = activeTeamId;
      _teamsRevision += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomePage(
            user: widget.user,
            identityGateway: widget.identityGateway,
            teamGateway: widget.teamGateway,
            selectedTeamId: _selectedTeamId,
            teamsRevision: _teamsRevision,
            onOpenTeam: () => _selectTab(2),
          ),
          const _ComingSoonPage(
            key: Key('calendar-page'),
            title: 'Calendrier',
            icon: Icons.calendar_month_outlined,
            message:
                'Les matchs et entraînements seront disponibles dans une prochaine étape.',
          ),
          TeamPage(
            teamGateway: widget.teamGateway,
            playerGateway: widget.playerGateway,
            selectedTeamId: _selectedTeamId,
            onTeamSelected: _selectTeam,
            onTeamsChanged: _teamsChanged,
          ),
          const _ComingSoonPage(
            key: Key('stats-page'),
            title: 'Stats',
            icon: Icons.bar_chart_outlined,
            message:
                'Les statistiques joueurs, équipe et management arriveront plus tard.',
          ),
          _ProfilePage(
            key: const Key('profile-page'),
            user: widget.user,
            onSignOut: widget.onSignOut,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(
            key: Key('nav-home'),
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          NavigationDestination(
            key: Key('nav-calendar'),
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Calendrier',
          ),
          NavigationDestination(
            key: Key('nav-team'),
            icon: Icon(Icons.groups_2_outlined),
            selectedIcon: Icon(Icons.groups_2),
            label: 'Équipe',
          ),
          NavigationDestination(
            key: Key('nav-stats'),
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
          NavigationDestination(
            key: Key('nav-profile'),
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _ComingSoonPage extends StatelessWidget {
  const _ComingSoonPage({
    required this.title,
    required this.icon,
    required this.message,
    super.key,
  });

  final String title;
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: colors.primaryContainer,
                      foregroundColor: colors.onPrimaryContainer,
                      child: Icon(icon, size: 32),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      title,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage({
    required this.user,
    required this.onSignOut,
    super.key,
  });

  final AuthUser user;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final displayName = user.displayName?.trim();
    final email = user.email?.trim();

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: colors.primaryContainer,
                        foregroundColor: colors.onPrimaryContainer,
                        child: const Icon(Icons.person, size: 32),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      displayName?.isNotEmpty == true
                          ? displayName!
                          : 'Mon compte',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                    ),
                    if (email?.isNotEmpty == true) ...[
                      const SizedBox(height: 6),
                      Text(
                        email!,
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ],
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      key: const Key('profile-sign-out'),
                      onPressed: onSignOut,
                      icon: const Icon(Icons.logout),
                      label: const Text('Se déconnecter'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
