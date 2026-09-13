import { Module } from '@nestjs/common';
import { PrismaModule } from '../../infrastructure/prisma/prisma.module.js';
import { CreatePlayerService } from './create-player.service.js';
import { ListPlayersService } from './list-players.service.js';
import {
  ClaimPlayerInvitationService,
  CreatePlayerInvitationService,
} from './player-invitation.service.js';
import { PrismaRosterRepository } from './prisma-roster.repository.js';
import { ROSTER_REPOSITORY } from './roster.repository.js';
import {
  PlayerInvitationController,
  RosterController,
} from './roster.controller.js';

@Module({
  imports: [PrismaModule],
  controllers: [RosterController, PlayerInvitationController],
  providers: [
    CreatePlayerService,
    ListPlayersService,
    CreatePlayerInvitationService,
    ClaimPlayerInvitationService,
    { provide: ROSTER_REPOSITORY, useClass: PrismaRosterRepository },
  ],
})
export class RosterModule {}
