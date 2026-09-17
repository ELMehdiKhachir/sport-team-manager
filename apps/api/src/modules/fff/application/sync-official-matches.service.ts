import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import {
  hasTeamPermission,
  TeamPermission,
} from '../../team/team-permission.js';
import { FffSyncService } from './fff-sync.service.js';
import { OfficialMatchQueryRepository } from './official-match-query.repository.js';

@Injectable()
export class SyncOfficialMatchesService {
  constructor(
    private readonly matches: OfficialMatchQueryRepository,
    private readonly sync: FffSyncService,
  ) {}

  async execute(firebaseUid: string, teamId: string) {
    const roles = await this.matches.getMembershipRoles(firebaseUid, teamId);
    if (!hasTeamPermission(roles, TeamPermission.FFF_SYNC)) {
      throw new ForbiddenException('FFF synchronization permission is required.');
    }

    const link = await this.matches.getOfficialTeamLink(teamId);
    if (!link) {
      throw new NotFoundException('No official FFF link is configured for this team.');
    }

    return this.sync.syncCompetition({
      teamId,
      competition: {
        externalId: link.externalCompetitionId,
        // The current DOFA club schedule endpoint is scoped by club id.
        // Keep that provider-specific detail here until the gateway contract
        // grows a dedicated externalClubId field.
        externalTeamId: link.externalClubId,
        name: link.competitionName,
        seasonLabel: link.seasonLabel ?? undefined,
      },
    });
  }
}
