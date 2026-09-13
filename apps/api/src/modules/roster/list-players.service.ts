import { ForbiddenException, Inject, Injectable } from '@nestjs/common';
import {
  ROSTER_REPOSITORY,
  RosterRepository,
} from './roster.repository.js';

@Injectable()
export class ListPlayersService {
  constructor(
    @Inject(ROSTER_REPOSITORY)
    private readonly roster: RosterRepository,
  ) {}

  async execute(firebaseUid: string, teamId: string) {
    const roles = await this.roster.getMembershipRoles(firebaseUid, teamId);
    if (!roles) {
      throw new ForbiddenException('Team membership is required.');
    }
    return this.roster.list(teamId);
  }
}
