import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiCreatedResponse,
  ApiForbiddenResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import { CurrentFirebaseIdentity } from '../../infrastructure/firebase/current-firebase-identity.decorator.js';
import { FirebaseAuthGuard } from '../../infrastructure/firebase/firebase-auth.guard.js';
import type { FirebaseIdentity } from '../../infrastructure/firebase/firebase-identity.js';
import { CreatePlayerDto } from './create-player.dto.js';
import { CreatePlayerService } from './create-player.service.js';
import { ListPlayersService } from './list-players.service.js';

@ApiTags('roster')
@ApiBearerAuth()
@UseGuards(FirebaseAuthGuard)
@Controller('teams/:teamId/players')
export class RosterController {
  constructor(
    private readonly createPlayer: CreatePlayerService,
    private readonly listPlayers: ListPlayersService,
  ) {}

  @Get()
  @ApiOperation({ summary: 'List players of a team' })
  @ApiOkResponse({ description: 'Team roster' })
  @ApiForbiddenResponse({ description: 'The user is not a member of this team' })
  list(
    @Param('teamId') teamId: string,
    @CurrentFirebaseIdentity() identity: FirebaseIdentity,
  ) {
    return this.listPlayers.execute(identity.firebaseUid, teamId);
  }

  @Post()
  @ApiOperation({ summary: 'Pre-create a player without requiring an account' })
  @ApiCreatedResponse({ description: 'Player profile created' })
  @ApiForbiddenResponse({ description: 'Roster management is not allowed' })
  create(
    @Param('teamId') teamId: string,
    @Body() body: CreatePlayerDto,
    @CurrentFirebaseIdentity() identity: FirebaseIdentity,
  ) {
    return this.createPlayer.execute({
      firebaseUid: identity.firebaseUid,
      teamId,
      firstName: body.firstName,
      lastName: body.lastName,
      primaryPosition: body.primaryPosition,
      secondaryPosition: body.secondaryPosition,
      shirtNumber: body.shirtNumber,
      dominantFoot: body.dominantFoot,
    });
  }
}
