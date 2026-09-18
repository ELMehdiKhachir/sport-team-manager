import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../infrastructure/prisma/prisma.service.js';
import {
  OfficialMatchQueryRepository,
  type OfficialTeamLink,
} from '../application/official-match-query.repository.js';

const officialTeamLinkSelect = {
  provider: true,
  externalClubId: true,
  externalTeamId: true,
  externalCompetitionId: true,
  competitionName: true,
  seasonLabel: true,
} as const;

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

  getOfficialTeamLink(teamId: string) {
    return this.prisma.teamOfficialLink.findUnique({
      where: { teamId },
      select: officialTeamLinkSelect,
    });
  }

  saveOfficialTeamLink(teamId: string, link: OfficialTeamLink) {
    return this.prisma.teamOfficialLink.upsert({
      where: { teamId },
      create: { teamId, ...link },
      update: link,
      select: officialTeamLinkSelect,
    });
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
