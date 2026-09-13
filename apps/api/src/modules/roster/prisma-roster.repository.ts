import { Injectable } from '@nestjs/common';
import { TeamRole } from '../../generated/prisma/enums.js';
import { PrismaService } from '../../infrastructure/prisma/prisma.service.js';
import {
  type ClaimInviteInput,
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

  async findById(
    teamId: string,
    playerId: string,
  ): Promise<PlayerSummary | null> {
    const player = await this.prisma.playerProfile.findFirst({
      where: { id: playerId, teamId },
    });
    return player ? this.toSummary(player) : null;
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

  async saveInvite(
    playerId: string,
    tokenHash: string,
    expiresAt: Date,
  ): Promise<void> {
    await this.prisma.playerProfile.update({
      where: { id: playerId },
      data: { inviteTokenHash: tokenHash, inviteExpiresAt: expiresAt },
    });
  }

  async claimInvite(input: ClaimInviteInput): Promise<PlayerSummary | null> {
    return this.prisma.$transaction(async (tx) => {
      const player = await tx.playerProfile.findFirst({
        where: {
          inviteTokenHash: input.tokenHash,
          inviteExpiresAt: { gt: input.now },
          userId: null,
        },
      });
      if (!player) return null;

      const user = await tx.user.upsert({
        where: { firebaseUid: input.firebaseUid },
        update: {
          email: input.email,
          displayName: input.displayName,
        },
        create: {
          firebaseUid: input.firebaseUid,
          email: input.email,
          displayName: input.displayName,
        },
      });

      const membership = await tx.teamMembership.findUnique({
        where: { userId_teamId: { userId: user.id, teamId: player.teamId } },
      });

      if (membership) {
        if (!membership.roles.includes(TeamRole.PLAYER)) {
          await tx.teamMembership.update({
            where: { id: membership.id },
            data: { roles: [...membership.roles, TeamRole.PLAYER] },
          });
        }
      } else {
        await tx.teamMembership.create({
          data: {
            userId: user.id,
            teamId: player.teamId,
            roles: [TeamRole.PLAYER],
          },
        });
      }

      const claimed = await tx.playerProfile.update({
        where: { id: player.id },
        data: {
          userId: user.id,
          inviteTokenHash: null,
          inviteExpiresAt: null,
        },
      });

      return this.toSummary(claimed);
    });
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
