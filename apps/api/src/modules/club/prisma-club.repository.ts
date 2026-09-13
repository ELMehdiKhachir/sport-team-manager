import { Injectable } from '@nestjs/common';
import { TeamRole } from '../../generated/prisma/enums.js';
import { PrismaService } from '../../infrastructure/prisma/prisma.service.js';
import { ClubRepository, type CreatedClubTeam } from './club.repository.js';

@Injectable()
export class PrismaClubRepository implements ClubRepository {
  constructor(private readonly prisma: PrismaService) {}

  async createWithInitialTeam({
    identity,
    clubName,
    teamName,
  }: Parameters<
    ClubRepository['createWithInitialTeam']
  >[0]): Promise<CreatedClubTeam> {
    return this.prisma.$transaction(async (transaction) => {
      const user = await transaction.user.upsert({
        where: { firebaseUid: identity.firebaseUid },
        create: {
          firebaseUid: identity.firebaseUid,
          email: identity.email,
          displayName: identity.displayName,
        },
        update: {
          email: identity.email,
          displayName: identity.displayName,
        },
      });

      const club = await transaction.club.create({ data: { name: clubName } });
      const team = await transaction.team.create({
        data: {
          name: teamName,
          clubId: club.id,
          memberships: {
            create: {
              userId: user.id,
              roles: [TeamRole.OWNER_MANAGER],
            },
          },
        },
      });

      return {
        club: { id: club.id, name: club.name },
        team: { id: team.id, name: team.name },
        roles: [TeamRole.OWNER_MANAGER],
      };
    });
  }
}
