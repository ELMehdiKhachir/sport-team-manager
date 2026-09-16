import {
  ImportedOfficialCompetition,
  ImportedOfficialMatch,
} from './fff-mapper.js';

export abstract class OfficialMatchRepository {
  abstract saveSync(input: {
    teamId: string;
    competition: ImportedOfficialCompetition;
    matches: ImportedOfficialMatch[];
    syncedAt: Date;
  }): Promise<void>;
}
