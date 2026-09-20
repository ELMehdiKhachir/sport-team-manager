import { BadRequestException, ForbiddenException } from '@nestjs/common';
import { vi } from 'vitest';
import { ConfigureOfficialTeamLinkService } from './configure-official-team-link.service.js';
import { OfficialMatchQueryRepository } from './official-match-query.repository.js';

describe('ConfigureOfficialTeamLinkService', () => {
  it('stores distinct club, team and competition identifiers', async () => {
    const repository = {
      getMembershipRoles: vi.fn().mockResolvedValue(['OWNER_MANAGER']),
      saveOfficialTeamLink: vi.fn().mockImplementation((_, link) => link),
    } as unknown as OfficialMatchQueryRepository;
    const service = new ConfigureOfficialTeamLinkService(repository);

    await service.execute('firebase-user', 'team-1', {
      externalClubId: ' club-42 ',
      externalTeamId: ' team-7 ',
      externalCompetitionId: ' competition-3 ',
      competitionName: ' D2 FUTSAL ',
      seasonLabel: ' 2026-2027 ',
    });

    expect(repository.saveOfficialTeamLink).toHaveBeenCalledWith('team-1', {
      provider: 'FFF',
      externalClubId: 'club-42',
      externalTeamId: 'team-7',
      externalCompetitionId: 'competition-3',
      competitionName: 'D2 FUTSAL',
      seasonLabel: '2026-2027',
    });
  });

  it('rejects an incomplete official link', async () => {
    const repository = {
      getMembershipRoles: vi.fn().mockResolvedValue(['OWNER_MANAGER']),
      saveOfficialTeamLink: vi.fn(),
    } as unknown as OfficialMatchQueryRepository;
    const service = new ConfigureOfficialTeamLinkService(repository);

    await expect(
      service.execute('firebase-user', 'team-1', {
        externalClubId: 'club-42',
        externalTeamId: ' ',
        externalCompetitionId: 'competition-3',
        competitionName: 'D2 FUTSAL',
      }),
    ).rejects.toBeInstanceOf(BadRequestException);
    expect(repository.saveOfficialTeamLink).not.toHaveBeenCalled();
  });

  it('keeps configuration restricted to authorized roles', async () => {
    const repository = {
      getMembershipRoles: vi.fn().mockResolvedValue(['PLAYER']),
      saveOfficialTeamLink: vi.fn(),
    } as unknown as OfficialMatchQueryRepository;
    const service = new ConfigureOfficialTeamLinkService(repository);

    await expect(
      service.execute('firebase-user', 'team-1', {
        externalClubId: 'club-42',
        externalTeamId: 'team-7',
        externalCompetitionId: 'competition-3',
        competitionName: 'D2 FUTSAL',
      }),
    ).rejects.toBeInstanceOf(ForbiddenException);
  });
});
