abstract final class TeamPermission {
  static const viewRoster = 'VIEW_ROSTER';
  static const manageRoster = 'MANAGE_ROSTER';
  static const invitePlayer = 'INVITE_PLAYER';
  static const manageTeamMembers = 'MANAGE_TEAM_MEMBERS';
  static const fffSync = 'FFF_SYNC';
  static const makeSportingDecisions = 'MAKE_SPORTING_DECISIONS';
  static const recordLiveEvents = 'RECORD_LIVE_EVENTS';
  static const viewManagementStats = 'VIEW_MANAGEMENT_STATS';
  static const respondAvailability = 'RESPOND_AVAILABILITY';
}

enum TeamInvitationRole {
  coach('COACH', 'Coach'),
  staffAssistant('STAFF_ASSISTANT', 'Staff / Assistant');

  const TeamInvitationRole(this.apiValue, this.label);
  final String apiValue;
  final String label;

  static TeamInvitationRole fromApi(String value) => values.firstWhere(
        (role) => role.apiValue == value,
        orElse: () => throw ArgumentError('Unknown team role: $value'),
      );
}

class TeamMemberInvitation {
  const TeamMemberInvitation({
    required this.token,
    required this.role,
    required this.expiresAt,
  });

  final String token;
  final TeamInvitationRole role;
  final DateTime expiresAt;
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

  Future<TeamMemberInvitation> createMemberInvitation({
    required String teamId,
    required TeamInvitationRole role,
  });

  Future<TeamSummary> claimMemberInvitation(String token);
}
