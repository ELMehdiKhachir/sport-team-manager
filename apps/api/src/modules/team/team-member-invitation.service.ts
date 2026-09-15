import {
  BadRequestException,
  ForbiddenException,
  Inject,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { createHash, randomBytes } from 'node:crypto';
import { TeamRole } from '../../generated/prisma/enums.js';
import type { FirebaseIdentity } from '../../infrastructure/firebase/firebase-identity.js';
import {
  hasTeamPermission,
  permissionsForTeamRoles,
  TeamPermission,
} from './team-permission.js';
import {
  TEAM_MEMBER_INVITATION_REPOSITORY,
  TeamMemberInvitationRepository,
} from './team-member-invitation.repository.js';

const INVITE_TTL_MS = 7 * 24 * 60 * 60 * 1000;
const INVITABLE_ROLES = [TeamRole.COACH, TeamRole.STAFF_ASSISTANT] as const;

function hashToken(token: string): string {
  return createHash('sha256').update(token).digest('hex');
}

@Injectable()
export class CreateTeamMemberInvitationService {
  constructor(
    @Inject(TEAM_MEMBER_INVITATION_REPOSITORY)
    private readonly invitations: TeamMemberInvitationRepository,
  ) {}

  async execute(firebaseUid: string, teamId: string, requestedRole: string) {
    const roles = await this.invitations.getMembershipRoles(
      firebaseUid,
      teamId,
    );
    if (!hasTeamPermission(roles, TeamPermission.MANAGE_TEAM_MEMBERS)) {
      throw new ForbiddenException('Team membership management is not allowed');
    }
    if (
      !INVITABLE_ROLES.includes(
        requestedRole as (typeof INVITABLE_ROLES)[number],
      )
    ) {
      throw new BadRequestException('Only coach or staff roles can be invited');
    }

    const role = requestedRole as (typeof INVITABLE_ROLES)[number];
    const token = randomBytes(32).toString('base64url');
    const expiresAt = new Date(Date.now() + INVITE_TTL_MS);
    await this.invitations.saveInvitation(
      teamId,
      role,
      hashToken(token),
      expiresAt,
    );

    return { token, role, expiresAt: expiresAt.toISOString() };
  }
}

@Injectable()
export class ClaimTeamMemberInvitationService {
  constructor(
    @Inject(TEAM_MEMBER_INVITATION_REPOSITORY)
    private readonly invitations: TeamMemberInvitationRepository,
  ) {}

  async execute(identity: FirebaseIdentity, token: string) {
    const normalized = token?.trim();
    if (!normalized || normalized.length < 20) {
      throw new UnauthorizedException('Invitation token is invalid');
    }

    const team = await this.invitations.claimInvitation({
      tokenHash: hashToken(normalized),
      now: new Date(),
      firebaseUid: identity.firebaseUid,
      email: identity.email,
      displayName: identity.displayName,
    });
    if (!team) {
      throw new UnauthorizedException(
        'Invitation is invalid, expired or already used',
      );
    }

    return {
      ...team,
      permissions: permissionsForTeamRoles(team.roles),
    };
  }
}
