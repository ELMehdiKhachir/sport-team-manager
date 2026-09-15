import {
  ConflictException,
  ForbiddenException,
  NotFoundException,
} from '@nestjs/common';
import {
  DominantFoot,
  PlayerPosition,
  TeamRole,
} from '../../generated/prisma/enums.js';
import {
  type ClaimInviteInput,
  type CreatePlayerRecord,
  type PlayerSummary,
  RosterRepository,
  type UpdatePlayerRecord,
} from './roster.repository.js';
import { UpdatePlayerService } from './update-player.service.js';

describe('UpdatePlayerService', () => {
  it('updates a player and can clear optional fields', async () => {
    const repository = new FakeRosterRepository([TeamRole.COACH]);
    const service = new UpdatePlayerService(repository);

    const result = await service.execute({
      firebaseUid: 'firebase-1',
      teamId: 'team-1',
      playerId: 'player-1',
      firstName: '  Amine ',
      lastName: ' Kaci ',
      secondaryPosition: null,
      shirtNumber: null,
      dominantFoot: null,
    });

    expect(result.lastName).toBe('Kaci');
    expect(repository.updated).toMatchObject({
      firstName: 'Amine',
      lastName: 'Kaci',
      secondaryPosition: null,
      shirtNumber: null,
      dominantFoot: null,
    });
    expect(repository.excludedPlayerId).toBe('player-1');
  });

  it('deactivates a player without deleting the profile', async () => {
    const repository = new FakeRosterRepository([TeamRole.OWNER_MANAGER]);
    const service = new UpdatePlayerService(repository);

    const result = await service.execute({
      firebaseUid: 'firebase-1',
      teamId: 'team-1',
      playerId: 'player-1',
      active: false,
    });

    expect(result.id).toBe('player-1');
    expect(result.active).toBe(false);
    expect(repository.updated?.active).toBe(false);
  });

  it('refuses updates for a player-only membership', async () => {
    const service = new UpdatePlayerService(
      new FakeRosterRepository([TeamRole.PLAYER]),
    );

    await expect(
      service.execute({
        firebaseUid: 'firebase-1',
        teamId: 'team-1',
        playerId: 'player-1',
        lastName: 'Kaci',
      }),
    ).rejects.toThrow(ForbiddenException);
  });

  it('does not update a player from another team', async () => {
    const repository = new FakeRosterRepository([TeamRole.OWNER_MANAGER]);
    repository.player = null;
    const service = new UpdatePlayerService(repository);

    await expect(
      service.execute({
        firebaseUid: 'firebase-1',
        teamId: 'team-1',
        playerId: 'player-other-team',
        lastName: 'Kaci',
      }),
    ).rejects.toThrow(NotFoundException);
  });

  it('refuses another player with the same name', async () => {
    const repository = new FakeRosterRepository([TeamRole.OWNER_MANAGER]);
    repository.duplicate = { ...playerFixture, id: 'player-2' };
    const service = new UpdatePlayerService(repository);

    await expect(
      service.execute({
        firebaseUid: 'firebase-1',
        teamId: 'team-1',
        playerId: 'player-1',
        lastName: 'Kaci',
      }),
    ).rejects.toThrow(ConflictException);
  });
});

const playerFixture: PlayerSummary = {
  id: 'player-1',
  teamId: 'team-1',
  firstName: 'Amine',
  lastName: 'Benali',
  primaryPosition: PlayerPosition.PIVOT,
  secondaryPosition: PlayerPosition.WINGER,
  shirtNumber: 10,
  dominantFoot: DominantFoot.RIGHT,
  active: true,
  accountAssociated: false,
};

class FakeRosterRepository extends RosterRepository {
  constructor(private readonly roles: TeamRole[] | null) {
    super();
  }

  player: PlayerSummary | null = playerFixture;
  duplicate: PlayerSummary | null = null;
  updated?: UpdatePlayerRecord;
  excludedPlayerId?: string;

  getMembershipRoles() {
    return Promise.resolve(this.roles);
  }

  list() {
    return Promise.resolve(this.player ? [this.player] : []);
  }

  findById() {
    return Promise.resolve(this.player);
  }

  findDuplicate(
    _teamId: string,
    _firstName: string,
    _lastName: string,
    excludePlayerId?: string,
  ) {
    this.excludedPlayerId = excludePlayerId;
    return Promise.resolve(this.duplicate);
  }

  create(_input: CreatePlayerRecord) {
    return Promise.resolve(playerFixture);
  }

  update(_teamId: string, _playerId: string, input: UpdatePlayerRecord) {
    this.updated = input;
    return Promise.resolve({ ...playerFixture, ...input });
  }

  saveInvite() {
    return Promise.resolve();
  }

  claimInvite(_input: ClaimInviteInput) {
    return Promise.resolve(playerFixture);
  }
}
