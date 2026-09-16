import { FffMapper } from './fff-mapper.js';

const mapper = new FffMapper();

const baseMatch = {
  externalId: 'match-1',
  startsAt: new Date('2026-09-20T18:00:00Z'),
  status: 'SCHEDULED' as const,
  homeTeam: { externalId: 'team-a', name: 'Team A' },
  awayTeam: { externalId: 'team-b', name: 'Team B' },
};

describe('FffMapper', () => {
  it('maps the active FFF team as home', () => {
    expect(mapper.mapMatch(baseMatch, 'team-a').venue).toBe('HOME');
  });

  it('maps the active FFF team as away', () => {
    expect(mapper.mapMatch(baseMatch, 'team-b').venue).toBe('AWAY');
  });

  it('keeps an unmatched team neutral instead of guessing', () => {
    expect(mapper.mapMatch(baseMatch, 'unknown-team').venue).toBe('NEUTRAL');
  });
});
