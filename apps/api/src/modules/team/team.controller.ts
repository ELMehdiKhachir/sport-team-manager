import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiBadRequestResponse,
  ApiCreatedResponse,
  ApiForbiddenResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import { CurrentFirebaseIdentity } from '../../infrastructure/firebase/current-firebase-identity.decorator.js';
import { FirebaseAuthGuard } from '../../infrastructure/firebase/firebase-auth.guard.js';
import type { FirebaseIdentity } from '../../infrastructure/firebase/firebase-identity.js';
import { ListMyTeamsService } from './list-my-teams.service.js';
import {
  ClaimTeamMemberInvitationDto,
  CreateTeamMemberInvitationDto,
} from './team-member-invitation.dto.js';
import {
  ClaimTeamMemberInvitationService,
  CreateTeamMemberInvitationService,
} from './team-member-invitation.service.js';

@ApiTags('teams')
@ApiBearerAuth()
@UseGuards(FirebaseAuthGuard)
@Controller('teams')
export class TeamController {
  constructor(
    private readonly listMyTeams: ListMyTeamsService,
    private readonly createMemberInvitation: CreateTeamMemberInvitationService,
  ) {}

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
          permissions: [
            'VIEW_ROSTER',
            'MANAGE_ROSTER',
            'INVITE_PLAYER',
            'MANAGE_TEAM_MEMBERS',
          ],
        },
      ],
    },
  })
  @ApiUnauthorizedResponse({ description: 'Missing or invalid Firebase token' })
  listMine(@CurrentFirebaseIdentity() identity: FirebaseIdentity) {
    return this.listMyTeams.execute(identity.firebaseUid);
  }

  @Post(':teamId/member-invitations')
  @ApiOperation({ summary: 'Invite a coach or staff member to a team' })
  @ApiCreatedResponse({ description: 'Secure invitation token created' })
  @ApiBadRequestResponse({ description: 'The invited role is not allowed' })
  @ApiForbiddenResponse({ description: 'Membership management is not allowed' })
  inviteMember(
    @Param('teamId') teamId: string,
    @Body() body: CreateTeamMemberInvitationDto,
    @CurrentFirebaseIdentity() identity: FirebaseIdentity,
  ) {
    return this.createMemberInvitation.execute(
      identity.firebaseUid,
      teamId,
      body.role,
    );
  }
}

@ApiTags('team-member-invitations')
@ApiBearerAuth()
@UseGuards(FirebaseAuthGuard)
@Controller('team-member-invitations')
export class TeamMemberInvitationController {
  constructor(
    private readonly claimMemberInvitation: ClaimTeamMemberInvitationService,
  ) {}

  @Post('claim')
  @ApiOperation({ summary: 'Join a team as invited coach or staff member' })
  @ApiOkResponse({ description: 'Team membership created or enriched' })
  claim(
    @Body() body: ClaimTeamMemberInvitationDto,
    @CurrentFirebaseIdentity() identity: FirebaseIdentity,
  ) {
    return this.claimMemberInvitation.execute(identity, body.token);
  }
}
