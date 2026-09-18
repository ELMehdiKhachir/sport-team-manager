import { ForbiddenException, Injectable } from '@nestjs/common';
import {
  hasTeamPermission,
  TeamPermission,
} from '../../team/team-permission.js';
import {
  OfficialMatchQueryRepository,
  type OfficialTeamLink,
} from './official-match-query.repository.js';

export interface ConfigureOfficialTeamLinkInput {
  externalClubId: string;
  externalTeamId?: string | null;
  externalCompetitionId: string;
  competitionName: string;
  seasonLabel?: string | null;
}

@Injectable()
export class ConfigureOfficialTeamLinkService {
  constructor(private readonly matches: OfficialMatchQueryRepository) {}

  async execute(
    firebaseUid: string,
    teamId: string,
    input: ConfigureOfficialTeamLinkInput,
  ) {
    const roles = await this.matches.getMembershipRoles(firebaseUid, teamId);
    if (!hasTeamPermission(roles, TeamPermission.FFF_SYNC)) {
      throw new ForbiddenException('FFF synchronization permission is required.');
    }

    const link: OfficialTeamLink = {
      provider: 'FFF',
      externalClubId: input.externalClubId.trim(),
      externalTeamId: input.externalTeamId?.trim() || null,
      externalCompetitionId: input.externalCompetitionId.trim(),
      competitionName: input.competitionName.trim(),
      seasonLabel: input.seasonLabel?.trim() || null,
    };

    return this.matches.saveOfficialTeamLink(teamId, link);
  }
}
