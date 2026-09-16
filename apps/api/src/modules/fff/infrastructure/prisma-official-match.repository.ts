import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../infrastructure/prisma/prisma.service.js';
import { OfficialMatchRepository } from '../application/official-match.repository.js';

@Injectable()
export class PrismaOfficialMatchRepository implements OfficialMatchRepository {
  constructor(private readonly prisma: PrismaService) {}

  async saveSync(input: Parameters<OfficialMatchRepository['saveSync']>[0]) {
    await this.prisma.$transaction(async (tx) => {
      const competition = await tx.officialCompetition.upsert({
        where: {
          teamId_provider_externalId: {
            teamId: input.teamId,
            provider: input.competition.provider,
            externalId: input.competition.externalId,
          },
        },
        update: {
          externalTeamId: input.competition.externalTeamId,
          name: input.competition.name,
          seasonLabel: input.competition.seasonLabel,
          lastSyncedAt: input.syncedAt,
        },
        create: {
          teamId: input.teamId,
          provider: input.competition.provider,
          externalId: input.competition.externalId,
          externalTeamId: input.competition.externalTeamId,
          name: input.competition.name,
          seasonLabel: input.competition.seasonLabel,
          lastSyncedAt: input.syncedAt,
        },
      });

      for (const match of input.matches) {
        await tx.officialMatch.upsert({
          where: {
            provider_externalId: {
              provider: match.provider,
              externalId: match.externalId,
            },
          },
          update: {
            teamId: input.teamId,
            competitionId: competition.id,
            startsAt: match.startsAt,
            venue: match.venue,
            status: match.status,
            homeTeamName: match.homeTeamName,
            awayTeamName: match.awayTeamName,
            homeExternalId: match.homeExternalId,
            awayExternalId: match.awayExternalId,
            lastSyncedAt: input.syncedAt,
          },
          create: {
            teamId: input.teamId,
            competitionId: competition.id,
            provider: match.provider,
            externalId: match.externalId,
            startsAt: match.startsAt,
            venue: match.venue,
            status: match.status,
            homeTeamName: match.homeTeamName,
            awayTeamName: match.awayTeamName,
            homeExternalId: match.homeExternalId,
            awayExternalId: match.awayExternalId,
            lastSyncedAt: input.syncedAt,
          },
        });
      }
    });
  }
}
