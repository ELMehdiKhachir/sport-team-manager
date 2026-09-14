import { BadRequestException, Inject, Injectable } from '@nestjs/common';
import type { FirebaseIdentity } from '../../infrastructure/firebase/firebase-identity.js';
import { permissionsForTeamRoles } from '../team/team-permission.js';
import {
  CLUB_REPOSITORY,
  ClubRepository,
  type CreatedClubTeam,
} from './club.repository.js';

@Injectable()
export class CreateClubWithTeamService {
  constructor(
    @Inject(CLUB_REPOSITORY)
    private readonly clubs: ClubRepository,
  ) {}

  async execute(input: {
    identity: FirebaseIdentity;
    clubName: string;
    teamName: string;
  }): Promise<
    CreatedClubTeam & {
      permissions: ReturnType<typeof permissionsForTeamRoles>;
    }
  > {
    const clubName = input.clubName?.trim();
    const teamName = input.teamName?.trim();

    if (!clubName || !teamName) {
      throw new BadRequestException(
        'Le nom du club et le nom de l’équipe sont obligatoires.',
      );
    }

    const created = await this.clubs.createWithInitialTeam({
      identity: input.identity,
      clubName,
      teamName,
    });
    return {
      ...created,
      permissions: permissionsForTeamRoles(created.roles),
    };
  }
}
