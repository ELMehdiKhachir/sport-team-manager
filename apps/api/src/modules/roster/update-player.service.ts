import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Inject,
  Injectable,
  NotFoundException,
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

export type UpdatePlayerCommand = {
  firebaseUid: string;
  teamId: string;
  playerId: string;
  firstName?: string;
  lastName?: string;
  primaryPosition?: PlayerPosition;
  secondaryPosition?: PlayerPosition | null;
  shirtNumber?: number | null;
  dominantFoot?: DominantFoot | null;
  active?: boolean;
};

@Injectable()
export class UpdatePlayerService {
  constructor(
    @Inject(ROSTER_REPOSITORY)
    private readonly roster: RosterRepository,
  ) {}

  async execute(command: UpdatePlayerCommand) {
    const roles = await this.roster.getMembershipRoles(
      command.firebaseUid,
      command.teamId,
    );
    if (!hasTeamPermission(roles, TeamPermission.MANAGE_ROSTER)) {
      throw new ForbiddenException('Roster management is not allowed.');
    }

    const player = await this.roster.findById(command.teamId, command.playerId);
    if (!player) {
      throw new NotFoundException('Player not found in this team.');
    }

    const firstName = (command.firstName ?? player.firstName).trim();
    const lastName = (command.lastName ?? player.lastName).trim();
    const primaryPosition = command.primaryPosition ?? player.primaryPosition;
    const secondaryPosition =
      command.secondaryPosition === undefined
        ? player.secondaryPosition
        : command.secondaryPosition;
    const shirtNumber =
      command.shirtNumber === undefined
        ? player.shirtNumber
        : command.shirtNumber;
    const dominantFoot =
      command.dominantFoot === undefined
        ? player.dominantFoot
        : command.dominantFoot;
    const active = command.active ?? player.active;

    if (!firstName || !lastName) {
      throw new BadRequestException('First name and last name are required.');
    }
    if (!Object.values(PlayerPosition).includes(primaryPosition)) {
      throw new BadRequestException('Invalid primary position.');
    }
    if (
      secondaryPosition !== null &&
      !Object.values(PlayerPosition).includes(secondaryPosition)
    ) {
      throw new BadRequestException('Invalid secondary position.');
    }
    if (
      dominantFoot !== null &&
      !Object.values(DominantFoot).includes(dominantFoot)
    ) {
      throw new BadRequestException('Invalid dominant foot.');
    }
    if (
      shirtNumber !== null &&
      (!Number.isInteger(shirtNumber) || shirtNumber < 0)
    ) {
      throw new BadRequestException('Invalid shirt number.');
    }

    const duplicate = await this.roster.findDuplicate(
      command.teamId,
      firstName,
      lastName,
      command.playerId,
    );
    if (duplicate) {
      throw new ConflictException('This player already exists in the team.');
    }

    const updated = await this.roster.update(
      command.teamId,
      command.playerId,
      {
        firstName,
        lastName,
        primaryPosition,
        secondaryPosition,
        shirtNumber,
        dominantFoot,
        active,
      },
    );
    if (!updated) {
      throw new NotFoundException('Player not found in this team.');
    }
    return updated;
  }
}
