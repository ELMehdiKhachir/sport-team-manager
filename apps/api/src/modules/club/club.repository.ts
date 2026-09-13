import type { FirebaseIdentity } from '../../infrastructure/firebase/firebase-identity.js';

export const CLUB_REPOSITORY = Symbol('CLUB_REPOSITORY');

export interface CreatedClubTeam {
  club: { id: string; name: string };
  team: { id: string; name: string };
  roles: string[];
}

export abstract class ClubRepository {
  abstract createWithInitialTeam(input: {
    identity: FirebaseIdentity;
    clubName: string;
    teamName: string;
  }): Promise<CreatedClubTeam>;
}
