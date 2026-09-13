import { Module } from '@nestjs/common';
import { ListMyTeamsService } from './list-my-teams.service.js';
import { PrismaTeamRepository } from './prisma-team.repository.js';
import { TEAM_REPOSITORY } from './team.repository.js';
import { TeamController } from './team.controller.js';

@Module({
  controllers: [TeamController],
  providers: [
    ListMyTeamsService,
    { provide: TEAM_REPOSITORY, useClass: PrismaTeamRepository },
  ],
})
export class TeamModule {}
