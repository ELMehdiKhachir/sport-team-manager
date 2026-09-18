import { Module } from '@nestjs/common';
import { PrismaModule } from '../../infrastructure/prisma/prisma.module.js';
import { ConfigureOfficialTeamLinkService } from './application/configure-official-team-link.service.js';
import { FffMapper } from './application/fff-mapper.js';
import { FffSyncService } from './application/fff-sync.service.js';
import { ListOfficialMatchesService } from './application/list-official-matches.service.js';
import { OfficialMatchQueryRepository } from './application/official-match-query.repository.js';
import { OfficialMatchRepository } from './application/official-match.repository.js';
import { SyncOfficialMatchesService } from './application/sync-official-matches.service.js';
import { FffGateway } from './domain/fff-gateway.js';
import { FffController } from './fff.controller.js';
import { DofaFffGateway } from './infrastructure/dofa-fff.gateway.js';
import { PrismaOfficialMatchQueryRepository } from './infrastructure/prisma-official-match-query.repository.js';
import { PrismaOfficialMatchRepository } from './infrastructure/prisma-official-match.repository.js';

@Module({
  imports: [PrismaModule],
  controllers: [FffController],
  providers: [
    FffMapper,
    FffSyncService,
    ListOfficialMatchesService,
    SyncOfficialMatchesService,
    ConfigureOfficialTeamLinkService,
    {
      provide: FffGateway,
      useClass: DofaFffGateway,
    },
    {
      provide: OfficialMatchRepository,
      useClass: PrismaOfficialMatchRepository,
    },
    {
      provide: OfficialMatchQueryRepository,
      useClass: PrismaOfficialMatchQueryRepository,
    },
  ],
  exports: [FffMapper, FffGateway, FffSyncService, OfficialMatchRepository],
})
export class FffModule {}
