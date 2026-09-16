import { FffGateway } from '../domain/fff-gateway.js';
import { FffMapper } from './fff-mapper.js';
import { FffSyncService } from './fff-sync.service.js';
import { OfficialMatchRepository } from './official-match.repository.js';

describe('FffSyncService', () => {
  const competition = {
    externalId: 'competition-1',
    externalTeamId: 'team-fff-1',
    name: 'Championnat Futsal',
  };

  it('persists mapped matches after a successful provider fetch', async () => {
    const gateway = {
      getCompetition: jest.fn().mockResolvedValue(competition),
      getSchedule: jest.fn().mockResolvedValue([
        {
          externalId: 'match-1',
          startsAt: new Date('2026-09-20T18:00:00Z'),
          status: 'SCHEDULED',
          homeTeam: { externalId: 'team-fff-1', name: 'Nous' },
          awayTeam: { externalId: 'team-fff-2', name: 'Adversaire' },
        },
      ]),
    } as unknown as FffGateway;
    const repository = {
      saveSync: jest.fn().mockResolvedValue(undefined),
    } as unknown as OfficialMatchRepository;

    const service = new FffSyncService(gateway, repository, new FffMapper());
    await expect(
      service.syncCompetition({ teamId: 'team-1', competition }),
    ).resolves.toEqual({ importedMatches: 1 });
    expect(repository.saveSync).toHaveBeenCalledTimes(1);
  });

  it('does not touch persisted data when the provider fails', async () => {
    const gateway = {
      getCompetition: jest.fn().mockRejectedValue(new Error('FFF unavailable')),
      getSchedule: jest.fn(),
    } as unknown as FffGateway;
    const repository = {
      saveSync: jest.fn(),
    } as unknown as OfficialMatchRepository;

    const service = new FffSyncService(gateway, repository, new FffMapper());
    await expect(
      service.syncCompetition({ teamId: 'team-1', competition }),
    ).rejects.toThrow('FFF unavailable');
    expect(repository.saveSync).not.toHaveBeenCalled();
  });
});
