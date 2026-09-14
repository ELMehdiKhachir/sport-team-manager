import { ListMyTeamsService } from './list-my-teams.service.js';
import { TeamRepository } from './team.repository.js';

describe('ListMyTeamsService', () => {
  it('returns memberships scoped to the Firebase user', async () => {
    const repository = new FakeTeamRepository();
    const service = new ListMyTeamsService(repository);

    const teams = await service.execute('firebase-user-1');

    expect(repository.lastFirebaseUid).toBe('firebase-user-1');
    expect(teams).toEqual([
      {
        id: 'team-1',
        name: 'Seniors 1',
        club: { id: 'club-1', name: 'Lyon Futsal' },
        roles: ['OWNER_MANAGER'],
        permissions: ['VIEW_ROSTER', 'MANAGE_ROSTER', 'INVITE_PLAYER'],
      },
    ]);
  });
});

class FakeTeamRepository extends TeamRepository {
  lastFirebaseUid?: string;

  findByFirebaseUid(firebaseUid: string) {
    this.lastFirebaseUid = firebaseUid;
    return Promise.resolve([
      {
        id: 'team-1',
        name: 'Seniors 1',
        club: { id: 'club-1', name: 'Lyon Futsal' },
        roles: ['OWNER_MANAGER'],
      },
    ]);
  }
}
