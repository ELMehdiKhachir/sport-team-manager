export type FffMatchStatus =
  | 'SCHEDULED'
  | 'POSTPONED'
  | 'CANCELLED'
  | 'PLAYED';

export interface FffCompetitionRef {
  externalId: string;
  externalTeamId: string;
  name: string;
  seasonLabel?: string;
}

export interface FffMatch {
  externalId: string;
  startsAt: Date;
  status: FffMatchStatus;
  homeTeam: {
    externalId?: string;
    name: string;
  };
  awayTeam: {
    externalId?: string;
    name: string;
  };
}

/**
 * Provider-independent boundary for official FFF data.
 *
 * Infrastructure adapters may change when the federation changes its public
 * delivery mechanism. Application/domain code must depend only on this port.
 */
export abstract class FffGateway {
  abstract getCompetition(
    competition: FffCompetitionRef,
  ): Promise<FffCompetitionRef>;

  abstract getSchedule(competition: FffCompetitionRef): Promise<FffMatch[]>;
}
