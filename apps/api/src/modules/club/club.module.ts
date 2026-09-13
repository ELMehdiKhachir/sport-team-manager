import { Module } from '@nestjs/common';
import { CLUB_REPOSITORY } from './club.repository.js';
import { ClubController } from './club.controller.js';
import { CreateClubWithTeamService } from './create-club-with-team.service.js';
import { PrismaClubRepository } from './prisma-club.repository.js';

@Module({
  controllers: [ClubController],
  providers: [
    CreateClubWithTeamService,
    { provide: CLUB_REPOSITORY, useClass: PrismaClubRepository },
  ],
})
export class ClubModule {}
