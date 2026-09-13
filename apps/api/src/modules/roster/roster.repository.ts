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

export abstract class RosterRepository {
  abstract getMembershipRoles(
    firebaseUid: string,
    teamId: string,
  ): Promise<TeamRole[] | null>;

  abstract list(teamId: string): Promise<PlayerSummary[]>;

  abstract findDuplicate(
    teamId: string,
    firstName: string,
    lastName: string,
  ): Promise<PlayerSummary | null>;

  abstract create(input: CreatePlayerRecord): Promise<PlayerSummary>;
}
