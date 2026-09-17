import { Injectable } from '@nestjs/common';
import {
  FffCompetitionRef,
  FffGateway,
  FffMatch,
  FffMatchStatus,
} from '../domain/fff-gateway.js';

type DofaMatch = {
  '@id'?: string;
  id?: string | number;
  date: string;
  time?: string | null;
  home_score?: number | null;
  away_score?: number | null;
  home: DofaTeam;
  away: DofaTeam;
  competition?: { name?: string };
};

type DofaTeam = {
  '@id'?: string;
  id?: string | number;
  short_name?: string;
  name?: string;
};

type HydraCollection<T> = {
  'hydra:member': T[];
};

@Injectable()
export class DofaFffGateway implements FffGateway {
  private readonly baseUrl = 'https://api-dofa.fff.fr/api';

  async getCompetition(
    competition: FffCompetitionRef,
  ): Promise<FffCompetitionRef> {
    return competition;
  }

  async getSchedule(competition: FffCompetitionRef): Promise<FffMatch[]> {
    const url = new URL(
      `${this.baseUrl}/clubs/${encodeURIComponent(competition.externalTeamId)}/matchs`,
    );
    url.searchParams.set('page', '1');

    const response = await fetch(url, {
      headers: { Accept: 'application/ld+json, application/json' },
    });
    if (!response.ok) {
      throw new Error(`FFF DOFA request failed with HTTP ${response.status}`);
    }

    const payload = (await response.json()) as HydraCollection<DofaMatch>;
    if (!Array.isArray(payload['hydra:member'])) {
      throw new Error('FFF DOFA returned an invalid match collection');
    }

    return payload['hydra:member']
      .filter(
        (match) =>
          !match.competition?.name ||
          match.competition.name.trim().toLowerCase() ===
            competition.name.trim().toLowerCase(),
      )
      .map((match) => this.mapMatch(match));
  }

  private mapMatch(match: DofaMatch): FffMatch {
    const externalId = this.externalId(match);
    const startsAt = this.startsAt(match);

    return {
      externalId,
      startsAt,
      status: this.status(match),
      homeTeam: this.mapTeam(match.home),
      awayTeam: this.mapTeam(match.away),
    };
  }

  private externalId(match: DofaMatch): string {
    const value = match.id ?? match['@id'];
    if (value === undefined) {
      throw new Error('FFF DOFA match has no stable identifier');
    }
    return String(value).split('/').filter(Boolean).pop() ?? String(value);
  }

  private mapTeam(team: DofaTeam): FffMatch['homeTeam'] {
    const id = team.id ?? team['@id'];
    const name = team.short_name ?? team.name;
    if (!name) {
      throw new Error('FFF DOFA team has no name');
    }
    return {
      ...(id === undefined
        ? {}
        : { externalId: String(id).split('/').filter(Boolean).pop() }),
      name,
    };
  }

  private startsAt(match: DofaMatch): Date {
    const time = match.time?.trim() || '00:00';
    const parsed = new Date(`${match.date}T${time}:00`);
    if (Number.isNaN(parsed.getTime())) {
      throw new Error(`FFF DOFA returned an invalid match date: ${match.date}`);
    }
    return parsed;
  }

  private status(match: DofaMatch): FffMatchStatus {
    if (
      typeof match.home_score === 'number' &&
      typeof match.away_score === 'number'
    ) {
      return 'PLAYED';
    }
    return 'SCHEDULED';
  }
}
