export interface OfficialCalendarMatch {
  id: string;
  provider: string;
  externalId: string;
  startsAt: Date;
  venue: string;
  status: string;
  homeTeamName: string;
  awayTeamName: string;
  competition: {
    id: string;
    name: string;
    seasonLabel: string | null;
  };
}

export interface OfficialTeamLink {
  provider: string;
  externalClubId: string;
  externalTeamId: string | null;
  externalCompetitionId: string;
  competitionName: string;
  seasonLabel: string | null;
}

export abstract class OfficialMatchQueryRepository {
  abstract getMembershipRoles(
    firebaseUid: string,
    teamId: string,
  ): Promise<string[] | null>;

  abstract getOfficialTeamLink(teamId: string): Promise<OfficialTeamLink | null>;

  abstract listByTeam(teamId: string): Promise<OfficialCalendarMatch[]>;
}
