import { BadRequestException } from '@nestjs/common';
import type { FirebaseIdentity } from '../../infrastructure/firebase/firebase-identity.js';
import { ClubRepository } from './club.repository.js';
import { CreateClubWithTeamService } from './create-club-with-team.service.js';

describe('CreateClubWithTeamService', () => {
  const identity: FirebaseIdentity = {
    firebaseUid: 'firebase-user-1',
    email: 'coach@example.com',
    displayName: 'Mehdi',
  };

  it('trims names and delegates the atomic creation to the repository', async () => {
    const repository = new FakeClubRepository();
    const service = new CreateClubWithTeamService(repository);

    const result = await service.execute({
      identity,
      clubName: '  Lyon Futsal  ',
      teamName: '  Seniors 1  ',
    });

    expect(repository.lastInput).toEqual({
      identity,
      clubName: 'Lyon Futsal',
      teamName: 'Seniors 1',
    });
    expect(result.roles).toEqual(['OWNER_MANAGER']);
    expect(result.permissions).toEqual([
      'VIEW_ROSTER',
      'MANAGE_ROSTER',
      'INVITE_PLAYER',
    ]);
  });

  it.each([
    { clubName: '', teamName: 'Seniors 1' },
    { clubName: 'Lyon Futsal', teamName: '   ' },
  ])('rejects empty names', async ({ clubName, teamName }) => {
    const service = new CreateClubWithTeamService(new FakeClubRepository());

    await expect(
      service.execute({ identity, clubName, teamName }),
    ).rejects.toThrow(BadRequestException);
  });
});

class FakeClubRepository extends ClubRepository {
  lastInput?: Parameters<ClubRepository['createWithInitialTeam']>[0];

  createWithInitialTeam(
    input: Parameters<ClubRepository['createWithInitialTeam']>[0],
  ) {
    this.lastInput = input;
    return Promise.resolve({
      club: { id: 'club-1', name: input.clubName },
      team: { id: 'team-1', name: input.teamName },
      roles: ['OWNER_MANAGER'],
    });
  }
}
