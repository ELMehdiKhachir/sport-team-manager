import type {
  DominantFoot,
  PlayerPosition,
  TeamRole,
} from '../../generated/prisma/enums.js';

export const ROSTER_REPOSITORY = Symbol('ROSTER_REPOSITORY');

export type PlayerSummary = {
  id: string;
  teamId: string;
  firstName: string;
  lastName: string;
  primaryPosition: PlayerPosition;
  secondaryPosition: PlayerPosition | null;
  shirtNumber: number | null;
  dominantFoot: DominantFoot | null;
  active: boolean;
  accountAssociated: boolean;
};

export type CreatePlayerRecord = {
  teamId: string;
  firstName: string;
  lastName: string;
  primaryPosition: PlayerPosition;
  secondaryPosition?: PlayerPosition;
  shirtNumber?: number;
  dominantFoot?: DominantFoot;
};

export type UpdatePlayerRecord = {
  firstName: string;
  lastName: string;
  primaryPosition: PlayerPosition;
  secondaryPosition: PlayerPosition | null;
  shirtNumber: number | null;
  dominantFoot: DominantFoot | null;
  active: boolean;
};

export type ClaimInviteInput = {
  tokenHash: string;
  now: Date;
  firebaseUid: string;
  email?: string;
  displayName?: string;
};

export abstract class RosterRepository {
  abstract getMembershipRoles(
    firebaseUid: string,
    teamId: string,
  ): Promise<TeamRole[] | null>;

  abstract list(teamId: string): Promise<PlayerSummary[]>;

  abstract findById(
    teamId: string,
    playerId: string,
  ): Promise<PlayerSummary | null>;

  abstract findDuplicate(
    teamId: string,
    firstName: string,
    lastName: string,
    excludePlayerId?: string,
  ): Promise<PlayerSummary | null>;

  abstract create(input: CreatePlayerRecord): Promise<PlayerSummary>;

  abstract update(
    teamId: string,
    playerId: string,
    input: UpdatePlayerRecord,
  ): Promise<PlayerSummary | null>;

  abstract saveInvite(
    playerId: string,
    tokenHash: string,
    expiresAt: Date,
  ): Promise<void>;

  abstract claimInvite(input: ClaimInviteInput): Promise<PlayerSummary | null>;
}
