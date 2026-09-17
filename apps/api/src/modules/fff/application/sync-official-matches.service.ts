import { ForbiddenException, Injectable } from '@nestjs/common';
import {
  hasTeamPermission,
  TeamPermission,
} from '../../team/team-permission.js';
import type { FffCompetitionRef } from '../domain/fff-gateway.js';
import { FffSyncService } from './fff-sync.service.js';
import { OfficialMatchQueryRepository } from './official-match-query.repository.js';

@Injectable()
export class SyncOfficialMatchesService {
  constructor(
    private readonly matches: OfficialMatchQueryRepository,
    private readonly sync: FffSyncService,
  ) {}

  async execute(
    firebaseUid: string,
    teamId: string,
    competition: FffCompetitionRef,
  ) {
    const roles = await this.matches.getMembershipRoles(firebaseUid, teamId);
    if (!hasTeamPermission(roles, TeamPermission.FFF_SYNC)) {
      throw new ForbiddenException('FFF synchronization permission is required.');
    }

    return this.sync.syncCompetition({ teamId, competition });
  }
}
