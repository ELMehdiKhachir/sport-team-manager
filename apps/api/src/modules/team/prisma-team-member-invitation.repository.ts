import { Injectable } from '@nestjs/common';
import type { TeamRole } from '../../generated/prisma/enums.js';
import { PrismaService } from '../../infrastructure/prisma/prisma.service.js';
import {
  type ClaimTeamMemberInviteInput,
  TeamMemberInvitationRepository,
} from './team-member-invitation.repository.js';

@Injectable()
export class PrismaTeamMemberInvitationRepository implements TeamMemberInvitationRepository {
  constructor(private readonly prisma: PrismaService) {}

  async getMembershipRoles(firebaseUid: string, teamId: string) {
    const membership = await this.prisma.teamMembership.findFirst({
      where: { teamId, user: { firebaseUid } },
      select: { roles: true },
    });
    return membership?.roles ?? null;
  }

  async saveInvitation(
    teamId: string,
    role: TeamRole,
    tokenHash: string,
    expiresAt: Date,
  ): Promise<void> {
    await this.prisma.teamMemberInvitation.create({
      data: { teamId, role, tokenHash, expiresAt },
    });
  }

  async claimInvitation(input: ClaimTeamMemberInviteInput) {
    return this.prisma.$transaction(async (tx) => {
      const invitation = await tx.teamMemberInvitation.findFirst({
        where: {
          tokenHash: input.tokenHash,
          expiresAt: { gt: input.now },
          claimedAt: null,
        },
      });
      if (!invitation) return null;

      const claim = await tx.teamMemberInvitation.updateMany({
        where: {
          id: invitation.id,
          tokenHash: input.tokenHash,
          expiresAt: { gt: input.now },
          claimedAt: null,
        },
        data: { claimedAt: input.now },
      });
      if (claim.count !== 1) return null;

      const user = await tx.user.upsert({
        where: { firebaseUid: input.firebaseUid },
        update: { email: input.email, displayName: input.displayName },
        create: {
          firebaseUid: input.firebaseUid,
          email: input.email,
          displayName: input.displayName,
        },
      });
      const existing = await tx.teamMembership.findUnique({
        where: {
          userId_teamId: { userId: user.id, teamId: invitation.teamId },
        },
      });
      const roles = existing
        ? existing.roles.includes(invitation.role)
          ? existing.roles
          : [...existing.roles, invitation.role]
        : [invitation.role];

      if (existing) {
        if (roles.length !== existing.roles.length) {
          await tx.teamMembership.update({
            where: { id: existing.id },
            data: { roles },
          });
        }
      } else {
        await tx.teamMembership.create({
          data: { userId: user.id, teamId: invitation.teamId, roles },
        });
      }

      const team = await tx.team.findUniqueOrThrow({
        where: { id: invitation.teamId },
        include: { club: true },
      });
      return {
        id: team.id,
        name: team.name,
        club: team.club ? { id: team.club.id, name: team.club.name } : null,
        roles,
      };
    });
  }
}
