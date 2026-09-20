class OfficialMatchSummary {
  const OfficialMatchSummary({
    required this.id,
    required this.provider,
    required this.startsAt,
    required this.venue,
    required this.status,
    required this.homeTeamName,
    required this.awayTeamName,
    required this.competitionName,
    this.seasonLabel,
  });

  final String id;
  final String provider;
  final DateTime startsAt;
  final String venue;
  final String status;
  final String homeTeamName;
  final String awayTeamName;
  final String competitionName;
  final String? seasonLabel;
}

class OfficialTeamLinkInput {
  const OfficialTeamLinkInput({
    required this.externalClubId,
    required this.externalTeamId,
    required this.externalCompetitionId,
    required this.competitionName,
    this.seasonLabel,
  });

  final String externalClubId;
  final String externalTeamId;
  final String externalCompetitionId;
  final String competitionName;
  final String? seasonLabel;
}

abstract interface class CalendarGateway {
  Future<List<OfficialMatchSummary>> getOfficialMatches(String teamId);

  Future<void> configureOfficialTeamLink(
    String teamId,
    OfficialTeamLinkInput link,
  );

  Future<int> syncOfficialMatches(String teamId);
}
