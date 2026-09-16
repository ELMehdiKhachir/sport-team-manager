import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../infrastructure/prisma/prisma.service.js';
import { OfficialMatchQueryRepository } from '../application/official-match-query.repository.js';

@Injectable()
export class PrismaOfficialMatchQueryRepository
  implements OfficialMatchQueryRepository
{
  constructor(private readonly prisma: PrismaService) {}

  async getMembershipRoles(firebaseUid: string, teamId: string) {
    const user = await this.prisma.user.findUnique({
      where: { firebaseUid },
      select: {
        memberships: {
          where: { teamId },
          select: { roles: true },
          take: 1,
        },
      },
    });

    return user?.memberships[0]?.roles ?? null;
  }

  listByTeam(teamId: string) {
    return this.prisma.officialMatch.findMany({
      where: { teamId },
      orderBy: { startsAt: 'asc' },
      select: {
        id: true,
        provider: true,
        externalId: true,
        startsAt: true,
        venue: true,
        status: true,
        homeTeamName: true,
        awayTeamName: true,
        competition: {
          select: {
            id: true,
            name: true,
            seasonLabel: true,
          },
        },
      },
    });
  }
}
