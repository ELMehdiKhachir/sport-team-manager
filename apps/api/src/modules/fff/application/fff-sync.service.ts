import { Injectable } from '@nestjs/common';
import { FffGateway, FffCompetitionRef } from '../domain/fff-gateway.js';
import { FffMapper } from './fff-mapper.js';
import { OfficialMatchRepository } from './official-match.repository.js';

@Injectable()
export class FffSyncService {
  constructor(
    private readonly gateway: FffGateway,
    private readonly repository: OfficialMatchRepository,
    private readonly mapper: FffMapper,
  ) {}

  async syncCompetition(input: {
    teamId: string;
    competition: FffCompetitionRef;
  }): Promise<{ importedMatches: number }> {
    // Fetch everything before opening the persistence transaction. If the
    // provider fails or returns unusable data, previously synced data remains.
    const competition = await this.gateway.getCompetition(input.competition);
    const matches = await this.gateway.getSchedule(competition);

    const mappedCompetition = this.mapper.mapCompetition(competition);
    const mappedMatches = matches.map((match) =>
      this.mapper.mapMatch(match, competition.externalTeamId),
    );

    await this.repository.saveSync({
      teamId: input.teamId,
      competition: mappedCompetition,
      matches: mappedMatches,
      syncedAt: new Date(),
    });

    return { importedMatches: mappedMatches.length };
  }
}
