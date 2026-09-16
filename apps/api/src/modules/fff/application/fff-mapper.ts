import { FffCompetitionRef, FffMatch } from '../domain/fff-gateway';

export type ImportedMatchVenue = 'HOME' | 'AWAY' | 'NEUTRAL';

export interface ImportedOfficialMatch {
  provider: 'FFF';
  externalId: string;
  startsAt: Date;
  status: FffMatch['status'];
  venue: ImportedMatchVenue;
  homeTeamName: string;
  awayTeamName: string;
  homeExternalId?: string;
  awayExternalId?: string;
}

export interface ImportedOfficialCompetition {
  provider: 'FFF';
  externalId: string;
  externalTeamId: string;
  name: string;
  seasonLabel?: string;
}

export class FffMapper {
  mapCompetition(
    competition: FffCompetitionRef,
  ): ImportedOfficialCompetition {
    return {
      provider: 'FFF',
      externalId: competition.externalId,
      externalTeamId: competition.externalTeamId,
      name: competition.name,
      seasonLabel: competition.seasonLabel,
    };
  }

  mapMatch(match: FffMatch, externalTeamId: string): ImportedOfficialMatch {
    return {
      provider: 'FFF',
      externalId: match.externalId,
      startsAt: match.startsAt,
      status: match.status,
      venue: this.resolveVenue(match, externalTeamId),
      homeTeamName: match.homeTeam.name,
      awayTeamName: match.awayTeam.name,
      homeExternalId: match.homeTeam.externalId,
      awayExternalId: match.awayTeam.externalId,
    };
  }

  private resolveVenue(
    match: FffMatch,
    externalTeamId: string,
  ): ImportedMatchVenue {
    if (match.homeTeam.externalId === externalTeamId) {
      return 'HOME';
    }
    if (match.awayTeam.externalId === externalTeamId) {
      return 'AWAY';
    }
    return 'NEUTRAL';
  }
}
