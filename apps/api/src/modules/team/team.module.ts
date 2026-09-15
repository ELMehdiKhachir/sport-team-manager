import { Module } from '@nestjs/common';
import { PrismaModule } from '../../infrastructure/prisma/prisma.module.js';
import { ListMyTeamsService } from './list-my-teams.service.js';
import { PrismaTeamMemberInvitationRepository } from './prisma-team-member-invitation.repository.js';
import { PrismaTeamRepository } from './prisma-team.repository.js';
import { TEAM_MEMBER_INVITATION_REPOSITORY } from './team-member-invitation.repository.js';
import {
  ClaimTeamMemberInvitationService,
  CreateTeamMemberInvitationService,
} from './team-member-invitation.service.js';
import { TEAM_REPOSITORY } from './team.repository.js';
import {
  TeamController,
  TeamMemberInvitationController,
} from './team.controller.js';

@Module({
  imports: [PrismaModule],
  controllers: [TeamController, TeamMemberInvitationController],
  providers: [
    ListMyTeamsService,
    CreateTeamMemberInvitationService,
    ClaimTeamMemberInvitationService,
    { provide: TEAM_REPOSITORY, useClass: PrismaTeamRepository },
    {
      provide: TEAM_MEMBER_INVITATION_REPOSITORY,
      useClass: PrismaTeamMemberInvitationRepository,
    },
  ],
})
export class TeamModule {}
