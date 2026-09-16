import { Module } from '@nestjs/common';
import { PrismaModule } from '../../infrastructure/prisma/prisma.module.js';
import { FffMapper } from './application/fff-mapper.js';
import { ListOfficialMatchesService } from './application/list-official-matches.service.js';
import { OfficialMatchQueryRepository } from './application/official-match-query.repository.js';
import { OfficialMatchRepository } from './application/official-match.repository.js';
import { FffController } from './fff.controller.js';
import { PrismaOfficialMatchQueryRepository } from './infrastructure/prisma-official-match-query.repository.js';
import { PrismaOfficialMatchRepository } from './infrastructure/prisma-official-match.repository.js';

@Module({
  imports: [PrismaModule],
  controllers: [FffController],
  providers: [
    FffMapper,
    ListOfficialMatchesService,
    {
      provide: OfficialMatchRepository,
      useClass: PrismaOfficialMatchRepository,
    },
    {
      provide: OfficialMatchQueryRepository,
      useClass: PrismaOfficialMatchQueryRepository,
    },
  ],
  exports: [FffMapper, OfficialMatchRepository],
})
export class FffModule {}
