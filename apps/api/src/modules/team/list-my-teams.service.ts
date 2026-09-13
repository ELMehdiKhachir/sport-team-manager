import { Inject, Injectable } from '@nestjs/common';
import { TEAM_REPOSITORY, TeamRepository } from './team.repository.js';
import type { TeamSummary } from './team-summary.js';

@Injectable()
export class ListMyTeamsService {
  constructor(
    @Inject(TEAM_REPOSITORY)
    private readonly teams: TeamRepository,
  ) {}

  execute(firebaseUid: string): Promise<TeamSummary[]> {
    return this.teams.findByFirebaseUid(firebaseUid);
  }
}
