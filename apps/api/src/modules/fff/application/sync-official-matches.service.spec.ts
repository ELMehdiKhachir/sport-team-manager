import { BadRequestException } from '@nestjs/common';
import { vi } from 'vitest';
import { FffSyncService } from './fff-sync.service.js';
import { OfficialMatchQueryRepository } from './official-match-query.repository.js';
import { SyncOfficialMatchesService } from './sync-official-matches.service.js';

describe('SyncOfficialMatchesService', () => {
  it('keeps club and team provider identifiers distinct', async () => {
    const matches = {
      getMembershipRoles: vi.fn().mockResolvedValue(['OWNER_MANAGER']),
      getOfficialTeamLink: vi.fn().mockResolvedValue({
        provider: 'FFF',
        externalClubId: 'club-42',
        externalTeamId: 'team-7',
        externalCompetitionId: 'competition-3',
        competitionName: 'D2 FUTSAL',
        seasonLabel: '2026-2027',
      }),
    } as unknown as OfficialMatchQueryRepository;
    const sync = {
      syncCompetition: vi.fn().mockResolvedValue({ importedMatches: 3 }),
    } as unknown as FffSyncService;

    const result = await new SyncOfficialMatchesService(matches, sync).execute(
      'firebase-user',
      'team-1',
    );

    expect(result).toEqual({ importedMatches: 3 });
    expect(sync.syncCompetition).toHaveBeenCalledWith({
      teamId: 'team-1',
      competition: {
        externalId: 'competition-3',
        externalClubId: 'club-42',
        externalTeamId: 'team-7',
        name: 'D2 FUTSAL',
        seasonLabel: '2026-2027',
      },
    });
  });

  it('rejects a legacy link without an official team identifier', async () => {
    const matches = {
      getMembershipRoles: vi.fn().mockResolvedValue(['OWNER_MANAGER']),
      getOfficialTeamLink: vi.fn().mockResolvedValue({
        provider: 'FFF',
        externalClubId: 'club-42',
        externalTeamId: null,
        externalCompetitionId: 'competition-3',
        competitionName: 'D2 FUTSAL',
        seasonLabel: null,
      }),
    } as unknown as OfficialMatchQueryRepository;
    const sync = {
      syncCompetition: vi.fn(),
    } as unknown as FffSyncService;

    await expect(
      new SyncOfficialMatchesService(matches, sync).execute(
        'firebase-user',
        'team-1',
      ),
    ).rejects.toBeInstanceOf(BadRequestException);
    expect(sync.syncCompetition).not.toHaveBeenCalled();
  });
});
