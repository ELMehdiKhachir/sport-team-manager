import {
  BadRequestException,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
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
  externalTeamId: string;
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
      throw new ForbiddenException(
        'FFF synchronization permission is required.',
      );
    }

    const externalClubId = input.externalClubId?.trim();
    const externalTeamId = input.externalTeamId?.trim();
    const externalCompetitionId = input.externalCompetitionId?.trim();
    const competitionName = input.competitionName?.trim();
    if (
      !externalClubId ||
      !externalTeamId ||
      !externalCompetitionId ||
      !competitionName
    ) {
      throw new BadRequestException(
        'Club, team and competition identifiers and competition name are required.',
      );
    }

    const link: OfficialTeamLink = {
      provider: 'FFF',
      externalClubId,
      externalTeamId,
      externalCompetitionId,
      competitionName,
      seasonLabel: input.seasonLabel?.trim() || null,
    };

    return this.matches.saveOfficialTeamLink(teamId, link);
  }
}
