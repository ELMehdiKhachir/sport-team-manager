import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
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
      throw new ForbiddenException(
        'FFF synchronization permission is required.',
      );
    }

    const link = await this.matches.getOfficialTeamLink(teamId);
    if (!link) {
      throw new NotFoundException(
        'No official FFF link is configured for this team.',
      );
    }
    if (!link.externalTeamId) {
      throw new BadRequestException(
        'The official FFF team identifier must be configured before synchronization.',
      );
    }

    return this.sync.syncCompetition({
      teamId,
      competition: {
        externalId: link.externalCompetitionId,
        externalClubId: link.externalClubId,
        externalTeamId: link.externalTeamId,
        name: link.competitionName,
        seasonLabel: link.seasonLabel ?? undefined,
      },
    });
  }
}
