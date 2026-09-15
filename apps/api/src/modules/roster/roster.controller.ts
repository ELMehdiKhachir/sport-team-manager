import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiBadRequestResponse,
  ApiConflictResponse,
  ApiCreatedResponse,
  ApiForbiddenResponse,
  ApiNotFoundResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import { CurrentFirebaseIdentity } from '../../infrastructure/firebase/current-firebase-identity.decorator.js';
import { FirebaseAuthGuard } from '../../infrastructure/firebase/firebase-auth.guard.js';
import type { FirebaseIdentity } from '../../infrastructure/firebase/firebase-identity.js';
import { ClaimPlayerInvitationDto } from './claim-player-invitation.dto.js';
import { CreatePlayerDto } from './create-player.dto.js';
import { CreatePlayerService } from './create-player.service.js';
import { ListPlayersService } from './list-players.service.js';
import { UpdatePlayerDto } from './update-player.dto.js';
import { UpdatePlayerService } from './update-player.service.js';
import {
  ClaimPlayerInvitationService,
  CreatePlayerInvitationService,
} from './player-invitation.service.js';

@ApiTags('roster')
@ApiBearerAuth()
@UseGuards(FirebaseAuthGuard)
@Controller('teams/:teamId/players')
export class RosterController {
  constructor(
    private readonly createPlayer: CreatePlayerService,
    private readonly listPlayers: ListPlayersService,
    private readonly updatePlayer: UpdatePlayerService,
    private readonly createInvitation: CreatePlayerInvitationService,
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

  @Patch(':playerId')
  @ApiOperation({ summary: 'Update a player profile in the team roster' })
  @ApiOkResponse({ description: 'Player profile updated' })
  @ApiBadRequestResponse({ description: 'Invalid player information' })
  @ApiConflictResponse({ description: 'A player with this name already exists' })
  @ApiForbiddenResponse({ description: 'Roster management is not allowed' })
  @ApiNotFoundResponse({ description: 'Player not found in this team' })
  update(
    @Param('teamId') teamId: string,
    @Param('playerId') playerId: string,
    @Body() body: UpdatePlayerDto,
    @CurrentFirebaseIdentity() identity: FirebaseIdentity,
  ) {
    return this.updatePlayer.execute({
      firebaseUid: identity.firebaseUid,
      teamId,
      playerId,
      firstName: body.firstName,
      lastName: body.lastName,
      primaryPosition: body.primaryPosition,
      secondaryPosition: body.secondaryPosition,
      shirtNumber: body.shirtNumber,
      dominantFoot: body.dominantFoot,
      active: body.active,
    });
  }

  @Post(':playerId/invitation')
  @ApiOperation({ summary: 'Create or regenerate a player invitation' })
  @ApiCreatedResponse({ description: 'Secure invitation token created' })
  @ApiForbiddenResponse({ description: 'Roster management is not allowed' })
  invite(
    @Param('teamId') teamId: string,
    @Param('playerId') playerId: string,
    @CurrentFirebaseIdentity() identity: FirebaseIdentity,
  ) {
    return this.createInvitation.execute(identity.firebaseUid, teamId, playerId);
  }
}

@ApiTags('roster')
@ApiBearerAuth()
@UseGuards(FirebaseAuthGuard)
@Controller('player-invitations')
export class PlayerInvitationController {
  constructor(private readonly claimInvitation: ClaimPlayerInvitationService) {}

  @Post('claim')
  @ApiOperation({ summary: 'Claim an existing player profile with an invitation' })
  @ApiOkResponse({ description: 'Player profile associated to the current user' })
  claim(
    @Body() body: ClaimPlayerInvitationDto,
    @CurrentFirebaseIdentity() identity: FirebaseIdentity,
  ) {
    return this.claimInvitation.execute(identity, body.token);
  }
}
