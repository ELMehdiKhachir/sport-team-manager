import type { TeamRole } from '../../generated/prisma/enums.js';
import type { TeamMembershipSummary } from './team-summary.js';

export const TEAM_MEMBER_INVITATION_REPOSITORY = Symbol(
  'TEAM_MEMBER_INVITATION_REPOSITORY',
);

export type ClaimTeamMemberInviteInput = {
  tokenHash: string;
  now: Date;
  firebaseUid: string;
  email?: string;
  displayName?: string;
};

export abstract class TeamMemberInvitationRepository {
  abstract getMembershipRoles(
    firebaseUid: string,
    teamId: string,
  ): Promise<TeamRole[] | null>;

  abstract saveInvitation(
    teamId: string,
    role: TeamRole,
    tokenHash: string,
    expiresAt: Date,
  ): Promise<void>;

  abstract claimInvitation(
    input: ClaimTeamMemberInviteInput,
  ): Promise<TeamMembershipSummary | null>;
}
