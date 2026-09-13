class TeamSummary {
  const TeamSummary({
    required this.id,
    required this.name,
    required this.roles,
    this.clubId,
    this.clubName,
  });

  final String id;
  final String name;
  final String? clubId;
  final String? clubName;
  final List<String> roles;
}

abstract interface class TeamGateway {
  Future<List<TeamSummary>> getMyTeams();

  Future<TeamSummary> createClubWithTeam({
    required String clubName,
    required String teamName,
  });
}
