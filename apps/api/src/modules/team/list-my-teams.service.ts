import { Inject, Injectable } from '@nestjs/common';
import {
  permissionsForTeamRoles,
} from './team-permission.js';
import { TEAM_REPOSITORY, TeamRepository } from './team.repository.js';
import type { TeamSummary } from './team-summary.js';

@Injectable()
export class ListMyTeamsService {
  constructor(
    @Inject(TEAM_REPOSITORY)
    private readonly teams: TeamRepository,
  ) {}

  async execute(firebaseUid: string): Promise<TeamSummary[]> {
    const teams = await this.teams.findByFirebaseUid(firebaseUid);
    return teams.map((team) => ({
      ...team,
      permissions: permissionsForTeamRoles(team.roles),
    }));
  }
}
