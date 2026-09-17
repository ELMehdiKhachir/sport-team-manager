import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiForbiddenResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import { CurrentFirebaseIdentity } from '../../infrastructure/firebase/current-firebase-identity.decorator.js';
import { FirebaseAuthGuard } from '../../infrastructure/firebase/firebase-auth.guard.js';
import type { FirebaseIdentity } from '../../infrastructure/firebase/firebase-identity.js';
import { ListOfficialMatchesService } from './application/list-official-matches.service.js';
import { SyncOfficialMatchesService } from './application/sync-official-matches.service.js';

class SyncOfficialMatchesBody {
  externalId!: string;
  externalTeamId!: string;
  name!: string;
  seasonLabel?: string;
}

@ApiTags('calendar')
@ApiBearerAuth()
@UseGuards(FirebaseAuthGuard)
@Controller('teams/:teamId/calendar/official-matches')
export class FffController {
  constructor(
    private readonly listOfficialMatches: ListOfficialMatchesService,
    private readonly syncOfficialMatches: SyncOfficialMatchesService,
  ) {}

  @Get()
  @ApiOperation({ summary: 'List persisted official matches of a team' })
  @ApiOkResponse({ description: 'Official matches ordered chronologically' })
  @ApiForbiddenResponse({ description: 'The user is not a member of this team' })
  list(
    @Param('teamId') teamId: string,
    @CurrentFirebaseIdentity() identity: FirebaseIdentity,
  ) {
    return this.listOfficialMatches.execute(identity.firebaseUid, teamId);
  }

  @Post('sync')
  @ApiOperation({ summary: 'Synchronize official FFF matches for a team' })
  @ApiOkResponse({ description: 'FFF synchronization completed' })
  @ApiForbiddenResponse({ description: 'FFF synchronization permission is required' })
  sync(
    @Param('teamId') teamId: string,
    @CurrentFirebaseIdentity() identity: FirebaseIdentity,
    @Body() body: SyncOfficialMatchesBody,
  ) {
    return this.syncOfficialMatches.execute(identity.firebaseUid, teamId, body);
  }
}
