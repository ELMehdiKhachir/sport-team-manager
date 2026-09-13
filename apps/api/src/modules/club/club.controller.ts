import { Body, Controller, Post, UseGuards } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiCreatedResponse,
  ApiOperation,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import { CurrentFirebaseIdentity } from '../../infrastructure/firebase/current-firebase-identity.decorator.js';
import { FirebaseAuthGuard } from '../../infrastructure/firebase/firebase-auth.guard.js';
import type { FirebaseIdentity } from '../../infrastructure/firebase/firebase-identity.js';
import { CreateClubWithTeamDto } from './create-club-with-team.dto.js';
import { CreateClubWithTeamService } from './create-club-with-team.service.js';

@ApiTags('clubs')
@ApiBearerAuth()
@UseGuards(FirebaseAuthGuard)
@Controller('clubs')
export class ClubController {
  constructor(private readonly createClub: CreateClubWithTeamService) {}

  @Post()
  @ApiOperation({ summary: 'Create a club and its first team' })
  @ApiCreatedResponse({
    schema: {
      example: {
        club: { id: 'club-id', name: 'Futsal Club de Lyon' },
        team: { id: 'team-id', name: 'Seniors 1' },
        roles: ['OWNER_MANAGER'],
      },
    },
  })
  @ApiUnauthorizedResponse({ description: 'Missing or invalid Firebase token' })
  create(
    @CurrentFirebaseIdentity() identity: FirebaseIdentity,
    @Body() body: CreateClubWithTeamDto,
  ) {
    return this.createClub.execute({
      identity,
      clubName: body.clubName,
      teamName: body.teamName,
    });
  }
}
