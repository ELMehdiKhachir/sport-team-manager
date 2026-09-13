import { Controller, Get, UseGuards } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import { CurrentFirebaseIdentity } from '../../infrastructure/firebase/current-firebase-identity.decorator.js';
import { FirebaseAuthGuard } from '../../infrastructure/firebase/firebase-auth.guard.js';
import type { FirebaseIdentity } from '../../infrastructure/firebase/firebase-identity.js';
import { ListMyTeamsService } from './list-my-teams.service.js';

@ApiTags('teams')
@ApiBearerAuth()
@UseGuards(FirebaseAuthGuard)
@Controller('teams')
export class TeamController {
  constructor(private readonly listMyTeams: ListMyTeamsService) {}

  @Get('mine')
  @ApiOperation({ summary: 'List teams of the authenticated user' })
  @ApiOkResponse({
    schema: {
      example: [
        {
          id: 'team-id',
          name: 'Seniors 1',
          club: { id: 'club-id', name: 'Futsal Club de Lyon' },
          roles: ['OWNER_MANAGER'],
        },
      ],
    },
  })
  @ApiUnauthorizedResponse({ description: 'Missing or invalid Firebase token' })
  listMine(@CurrentFirebaseIdentity() identity: FirebaseIdentity) {
    return this.listMyTeams.execute(identity.firebaseUid);
  }
}
