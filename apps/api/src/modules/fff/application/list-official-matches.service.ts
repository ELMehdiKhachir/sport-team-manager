import { ForbiddenException, Injectable } from '@nestjs/common';
import { OfficialMatchQueryRepository } from './official-match-query.repository.js';

@Injectable()
export class ListOfficialMatchesService {
  constructor(private readonly matches: OfficialMatchQueryRepository) {}

  async execute(firebaseUid: string, teamId: string) {
    const roles = await this.matches.getMembershipRoles(firebaseUid, teamId);
    if (!roles) {
      throw new ForbiddenException('Team membership is required.');
    }

    return this.matches.listByTeam(teamId);
  }
}
