abstract final class TeamPermission {
  static const viewRoster = 'VIEW_ROSTER';
  static const manageRoster = 'MANAGE_ROSTER';
  static const invitePlayer = 'INVITE_PLAYER';
  static const makeSportingDecisions = 'MAKE_SPORTING_DECISIONS';
  static const recordLiveEvents = 'RECORD_LIVE_EVENTS';
  static const viewManagementStats = 'VIEW_MANAGEMENT_STATS';
  static const respondAvailability = 'RESPOND_AVAILABILITY';
}

class TeamSummary {
  const TeamSummary({
    required this.id,
    required this.name,
    required this.roles,
    this.permissions = const [],
    this.clubId,
    this.clubName,
  });

  final String id;
  final String name;
  final String? clubId;
  final String? clubName;
  final List<String> roles;
  final List<String> permissions;

  bool allows(String permission) => permissions.contains(permission);
}

abstract interface class TeamGateway {
  Future<List<TeamSummary>> getMyTeams();

  Future<TeamSummary> createClubWithTeam({
    required String clubName,
    required String teamName,
  });
}
