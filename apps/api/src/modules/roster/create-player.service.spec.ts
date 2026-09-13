import { ConflictException, ForbiddenException } from '@nestjs/common';
import {
  DominantFoot,
  PlayerPosition,
  TeamRole,
} from '../../generated/prisma/enums.js';
import { CreatePlayerService } from './create-player.service.js';
import {
  type ClaimInviteInput,
  type CreatePlayerRecord,
  type PlayerSummary,
  RosterRepository,
} from './roster.repository.js';

describe('CreatePlayerService', () => {
  it('pre-creates a player for a manager without linking an account', async () => {
    const repository = new FakeRosterRepository([TeamRole.OWNER_MANAGER]);
    const service = new CreatePlayerService(repository);

    const result = await service.execute({
      firebaseUid: 'firebase-1',
      teamId: 'team-1',
      firstName: '  Amine ',
      lastName: ' Benali  ',
      primaryPosition: PlayerPosition.PIVOT,
      shirtNumber: 10,
      dominantFoot: DominantFoot.RIGHT,
    });

    expect(result.accountAssociated).toBe(false);
    expect(repository.created?.firstName).toBe('Amine');
    expect(repository.created?.lastName).toBe('Benali');
  });

  it('refuses roster changes for a player-only membership', async () => {
    const service = new CreatePlayerService(
      new FakeRosterRepository([TeamRole.PLAYER]),
    );

    await expect(
      service.execute({
        firebaseUid: 'firebase-1',
        teamId: 'team-1',
        firstName: 'Amine',
        lastName: 'Benali',
        primaryPosition: PlayerPosition.PIVOT,
      }),
    ).rejects.toThrow(ForbiddenException);
  });

  it('refuses an obvious duplicate in the same team', async () => {
    const repository = new FakeRosterRepository([TeamRole.COACH]);
    repository.duplicate = playerFixture;
    const service = new CreatePlayerService(repository);

    await expect(
      service.execute({
        firebaseUid: 'firebase-1',
        teamId: 'team-1',
        firstName: 'Amine',
        lastName: 'Benali',
        primaryPosition: PlayerPosition.PIVOT,
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
  secondaryPosition: null,
  shirtNumber: 10,
  dominantFoot: DominantFoot.RIGHT,
  accountAssociated: false,
};

class FakeRosterRepository extends RosterRepository {
  constructor(private readonly roles: TeamRole[] | null) {
    super();
  }

  created?: CreatePlayerRecord;
  duplicate: PlayerSummary | null = null;

  getMembershipRoles() {
    return Promise.resolve(this.roles);
  }

  list() {
    return Promise.resolve([]);
  }

  findById() {
    return Promise.resolve(playerFixture);
  }

  findDuplicate() {
    return Promise.resolve(this.duplicate);
  }

  create(input: CreatePlayerRecord) {
    this.created = input;
    return Promise.resolve({
      ...playerFixture,
      firstName: input.firstName,
      lastName: input.lastName,
      primaryPosition: input.primaryPosition,
      secondaryPosition: input.secondaryPosition ?? null,
      shirtNumber: input.shirtNumber ?? null,
      dominantFoot: input.dominantFoot ?? null,
    });
  }

  saveInvite() {
    return Promise.resolve();
  }

  claimInvite(_input: ClaimInviteInput) {
    return Promise.resolve(playerFixture);
  }
}
