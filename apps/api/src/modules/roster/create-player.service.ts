import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Inject,
  Injectable,
} from '@nestjs/common';
import {
  DominantFoot,
  PlayerPosition,
} from '../../generated/prisma/enums.js';
import {
  hasTeamPermission,
  TeamPermission,
} from '../team/team-permission.js';
import {
  ROSTER_REPOSITORY,
  RosterRepository,
} from './roster.repository.js';

export type CreatePlayerCommand = {
  firebaseUid: string;
  teamId: string;
  firstName: string;
  lastName: string;
  primaryPosition: PlayerPosition;
  secondaryPosition?: PlayerPosition;
  shirtNumber?: number;
  dominantFoot?: DominantFoot;
};

@Injectable()
export class CreatePlayerService {
  constructor(
    @Inject(ROSTER_REPOSITORY)
    private readonly roster: RosterRepository,
  ) {}

  async execute(command: CreatePlayerCommand) {
    const roles = await this.roster.getMembershipRoles(
      command.firebaseUid,
      command.teamId,
    );
    if (
      !hasTeamPermission(roles, TeamPermission.MANAGE_ROSTER)
    ) {
      throw new ForbiddenException('Roster management is not allowed.');
    }

    const firstName = command.firstName?.trim();
    const lastName = command.lastName?.trim();
    if (!firstName || !lastName) {
      throw new BadRequestException('First name and last name are required.');
    }
    if (!Object.values(PlayerPosition).includes(command.primaryPosition)) {
      throw new BadRequestException('Invalid primary position.');
    }
    if (
      command.secondaryPosition &&
      !Object.values(PlayerPosition).includes(command.secondaryPosition)
    ) {
      throw new BadRequestException('Invalid secondary position.');
    }
    if (
      command.dominantFoot &&
      !Object.values(DominantFoot).includes(command.dominantFoot)
    ) {
      throw new BadRequestException('Invalid dominant foot.');
    }
    if (
      command.shirtNumber !== undefined &&
      (!Number.isInteger(command.shirtNumber) || command.shirtNumber < 0)
    ) {
      throw new BadRequestException('Invalid shirt number.');
    }

    const duplicate = await this.roster.findDuplicate(
      command.teamId,
      firstName,
      lastName,
    );
    if (duplicate) {
      throw new ConflictException('This player already exists in the team.');
    }

    return this.roster.create({
      teamId: command.teamId,
      firstName,
      lastName,
      primaryPosition: command.primaryPosition,
      secondaryPosition: command.secondaryPosition,
      shirtNumber: command.shirtNumber,
      dominantFoot: command.dominantFoot,
    });
  }
}
