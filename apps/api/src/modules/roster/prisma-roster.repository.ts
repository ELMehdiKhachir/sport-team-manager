import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../infrastructure/prisma/prisma.service.js';
import {
  type CreatePlayerRecord,
  type PlayerSummary,
  RosterRepository,
} from './roster.repository.js';

@Injectable()
export class PrismaRosterRepository implements RosterRepository {
  constructor(private readonly prisma: PrismaService) {}

  async getMembershipRoles(firebaseUid: string, teamId: string) {
    const membership = await this.prisma.teamMembership.findFirst({
      where: { teamId, user: { firebaseUid } },
      select: { roles: true },
    });
    return membership?.roles ?? null;
  }

  async list(teamId: string): Promise<PlayerSummary[]> {
    const players = await this.prisma.playerProfile.findMany({
      where: { teamId },
      orderBy: [{ lastName: 'asc' }, { firstName: 'asc' }],
    });
    return players.map((player) => this.toSummary(player));
  }

  async findDuplicate(
    teamId: string,
    firstName: string,
    lastName: string,
  ): Promise<PlayerSummary | null> {
    const player = await this.prisma.playerProfile.findFirst({
      where: {
        teamId,
        firstName: { equals: firstName, mode: 'insensitive' },
        lastName: { equals: lastName, mode: 'insensitive' },
      },
    });
    return player ? this.toSummary(player) : null;
  }

  async create(input: CreatePlayerRecord): Promise<PlayerSummary> {
    const player = await this.prisma.playerProfile.create({
      data: {
        teamId: input.teamId,
        firstName: input.firstName,
        lastName: input.lastName,
        primaryPosition: input.primaryPosition,
        secondaryPosition: input.secondaryPosition,
        shirtNumber: input.shirtNumber,
        dominantFoot: input.dominantFoot,
      },
    });
    return this.toSummary(player);
  }

  private toSummary(player: {
    id: string;
    teamId: string;
    userId: string | null;
    firstName: string;
    lastName: string;
    primaryPosition: PlayerSummary['primaryPosition'];
    secondaryPosition: PlayerSummary['secondaryPosition'];
    shirtNumber: number | null;
    dominantFoot: PlayerSummary['dominantFoot'];
  }): PlayerSummary {
    return {
      id: player.id,
      teamId: player.teamId,
      firstName: player.firstName,
      lastName: player.lastName,
      primaryPosition: player.primaryPosition,
      secondaryPosition: player.secondaryPosition,
      shirtNumber: player.shirtNumber,
      dominantFoot: player.dominantFoot,
      accountAssociated: player.userId !== null,
    };
  }
}
