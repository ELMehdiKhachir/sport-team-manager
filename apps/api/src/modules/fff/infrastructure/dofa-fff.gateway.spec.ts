import { afterEach, describe, expect, it, vi } from 'vitest';
import { DofaFffGateway } from './dofa-fff.gateway.js';

describe('DofaFffGateway', () => {
  afterEach(() => vi.restoreAllMocks());

  it('maps and filters DOFA matches for the requested competition', async () => {
    const fetchMock = vi.spyOn(globalThis, 'fetch').mockResolvedValue(
      new Response(
        JSON.stringify({
          'hydra:member': [
            {
              '@id': '/api/matchs/42',
              date: '2026-10-03',
              time: '19:00',
              home_score: null,
              away_score: null,
              competition: { name: 'D2 FUTSAL' },
              home: {
                '@id': '/api/equipes/137104',
                short_name: 'NANTES DOULON B.',
              },
              away: { '@id': '/api/equipes/999', short_name: 'PESSAC FC' },
            },
            {
              '@id': '/api/matchs/43',
              date: '2026-10-04',
              competition: { name: 'AUTRE COMPETITION' },
              home: { short_name: 'A' },
              away: { short_name: 'B' },
            },
          ],
        }),
        { status: 200, headers: { 'Content-Type': 'application/json' } },
      ),
    );

    const gateway = new DofaFffGateway();
    const matches = await gateway.getSchedule({
      externalId: 'd2',
      externalClubId: 'club-137104',
      externalTeamId: '137104',
      name: 'D2 FUTSAL',
      seasonLabel: '2026-2027',
    });

    expect(fetchMock).toHaveBeenCalledOnce();
    expect(String(fetchMock.mock.calls[0]?.[0])).toContain(
      '/clubs/club-137104/matchs',
    );
    expect(matches).toHaveLength(1);
    expect(matches[0]).toMatchObject({
      externalId: '42',
      status: 'SCHEDULED',
      homeTeam: { externalId: '137104', name: 'NANTES DOULON B.' },
      awayTeam: { externalId: '999', name: 'PESSAC FC' },
    });
    expect(matches[0]?.startsAt.getFullYear()).toBe(2026);
    expect(matches[0]?.startsAt.getMonth()).toBe(9);
    expect(matches[0]?.startsAt.getDate()).toBe(3);
    expect(matches[0]?.startsAt.getHours()).toBe(19);
  });

  it('marks a scored match as played', async () => {
    vi.spyOn(globalThis, 'fetch').mockResolvedValue(
      new Response(
        JSON.stringify({
          'hydra:member': [
            {
              id: 7,
              date: '2026-05-02',
              time: '16:00',
              home_score: 4,
              away_score: 7,
              competition: { name: 'D2 FUTSAL' },
              home: { short_name: 'MARCOUVILLE CITY CP' },
              away: { short_name: 'NANTES DOULON B.' },
            },
          ],
        }),
        { status: 200, headers: { 'Content-Type': 'application/json' } },
      ),
    );

    const matches = await new DofaFffGateway().getSchedule({
      externalId: 'd2',
      externalClubId: 'club-137104',
      externalTeamId: '137104',
      name: 'D2 FUTSAL',
    });

    expect(matches[0]?.status).toBe('PLAYED');
  });

  it('fails without returning partial data when DOFA is unavailable', async () => {
    vi.spyOn(globalThis, 'fetch').mockResolvedValue(
      new Response(null, { status: 503 }),
    );

    await expect(
      new DofaFffGateway().getSchedule({
        externalId: 'd2',
        externalClubId: 'club-137104',
        externalTeamId: '137104',
        name: 'D2 FUTSAL',
      }),
    ).rejects.toThrow('HTTP 503');
  });
});
