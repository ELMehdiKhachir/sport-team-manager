import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller.js';
import { AppService } from './app.service.js';
import { FirebaseModule } from './infrastructure/firebase/firebase.module.js';
import { PrismaModule } from './infrastructure/prisma/prisma.module.js';
import { IdentityModule } from './modules/identity/identity.module.js';
import { ClubModule } from './modules/club/club.module.js';
import { TeamModule } from './modules/team/team.module.js';
import { RosterModule } from './modules/roster/roster.module.js';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PrismaModule,
    FirebaseModule,
    IdentityModule,
    ClubModule,
    TeamModule,
    RosterModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
