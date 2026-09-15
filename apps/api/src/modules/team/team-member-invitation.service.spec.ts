import {
  BadRequestException,
  ForbiddenException,
  UnauthorizedException,
} from '@nestjs/common';
import { TeamRole } from '../../generated/prisma/enums.js';
import type { FirebaseIdentity } from '../../infrastructure/firebase/firebase-identity.js';
import {
  type ClaimTeamMemberInviteInput,
  TeamMemberInvitationRepository,
} from './team-member-invitation.repository.js';
import {
  ClaimTeamMemberInvitationService,
  CreateTeamMemberInvitationService,
} from './team-member-invitation.service.js';
import { TeamPermission } from './team-permission.js';

describe('team member invitations', () => {
  it('lets a manager create an opaque coach invitation', async () => {
    const repository = new FakeInvitationRepository([TeamRole.OWNER_MANAGER]);
    const service = new CreateTeamMemberInvitationService(repository);

    const result = await service.execute(
      'firebase-manager',
      'team-1',
      TeamRole.COACH,
    );

    expect(result.token.length).toBeGreaterThanOrEqual(40);
    expect(result.role).toBe(TeamRole.COACH);
    expect(repository.saved).toMatchObject({
      teamId: 'team-1',
      role: TeamRole.COACH,
    });
    expect(repository.saved?.tokenHash).not.toBe(result.token);
  });

  it('does not let a coach invite privileged team members', async () => {
    const service = new CreateTeamMemberInvitationService(
      new FakeInvitationRepository([TeamRole.COACH]),
    );

    await expect(
      service.execute('firebase-coach', 'team-1', TeamRole.STAFF_ASSISTANT),
    ).rejects.toThrow(ForbiddenException);
  });

  it('never allows the manager role through an invitation', async () => {
    const service = new CreateTeamMemberInvitationService(
      new FakeInvitationRepository([TeamRole.OWNER_MANAGER]),
    );

    await expect(
      service.execute('firebase-manager', 'team-1', TeamRole.OWNER_MANAGER),
    ).rejects.toThrow(BadRequestException);
  });

  it('returns cumulative permissions after a valid claim', async () => {
    const repository = new FakeInvitationRepository(null);
    repository.claimedTeam = {
      id: 'team-1',
      name: 'Seniors 1',
      club: { id: 'club-1', name: 'Mon Club' },
      roles: [TeamRole.PLAYER, TeamRole.COACH],
    };
    const service = new ClaimTeamMemberInvitationService(repository);

    const result = await service.execute(
      identity,
      'valid-team-invitation-token-123456',
    );

    expect(result.roles).toEqual([TeamRole.PLAYER, TeamRole.COACH]);
    expect(result.permissions).toContain(
      TeamPermission.MAKE_SPORTING_DECISIONS,
    );
    expect(result.permissions).toContain(TeamPermission.RESPOND_AVAILABILITY);
  });

  it('refuses an invalid, expired or already used invitation', async () => {
    const service = new ClaimTeamMemberInvitationService(
      new FakeInvitationRepository(null),
    );

    await expect(
      service.execute(identity, 'invalid-team-invitation-token-123'),
    ).rejects.toThrow(UnauthorizedException);
  });
});

const identity: FirebaseIdentity = {
  firebaseUid: 'firebase-invitee',
  email: 'invitee@example.com',
  displayName: 'Nora',
};

class FakeInvitationRepository extends TeamMemberInvitationRepository {
  constructor(private readonly roles: TeamRole[] | null) {
    super();
  }

  saved?: {
    teamId: string;
    role: TeamRole;
    tokenHash: string;
    expiresAt: Date;
  };
  claimedTeam: Awaited<
    ReturnType<TeamMemberInvitationRepository['claimInvitation']>
  > = null;

  getMembershipRoles() {
    return Promise.resolve(this.roles);
  }

  saveInvitation(
    teamId: string,
    role: TeamRole,
    tokenHash: string,
    expiresAt: Date,
  ) {
    this.saved = { teamId, role, tokenHash, expiresAt };
    return Promise.resolve();
  }

  claimInvitation(_input: ClaimTeamMemberInviteInput) {
    return Promise.resolve(this.claimedTeam);
  }
}
