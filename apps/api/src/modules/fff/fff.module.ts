import { Module } from '@nestjs/common';
import { PrismaModule } from '../../infrastructure/prisma/prisma.module.js';
import { FffMapper } from './application/fff-mapper.js';
import { OfficialMatchRepository } from './application/official-match.repository.js';
import { PrismaOfficialMatchRepository } from './infrastructure/prisma-official-match.repository.js';

@Module({
  imports: [PrismaModule],
  providers: [
    FffMapper,
    {
      provide: OfficialMatchRepository,
      useClass: PrismaOfficialMatchRepository,
    },
  ],
  exports: [FffMapper, OfficialMatchRepository],
})
export class FffModule {}
