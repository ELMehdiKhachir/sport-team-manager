import type { TeamMembershipSummary } from './team-summary.js';

export const TEAM_REPOSITORY = Symbol('TEAM_REPOSITORY');

export abstract class TeamRepository {
  abstract findByFirebaseUid(
    firebaseUid: string,
  ): Promise<TeamMembershipSummary[]>;
}
