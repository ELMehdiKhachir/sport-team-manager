import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller.js';
import { AppService } from './app.service.js';
import { FirebaseModule } from './infrastructure/firebase/firebase.module.js';
import { PrismaModule } from './infrastructure/prisma/prisma.module.js';
import { IdentityModule } from './modules/identity/identity.module.js';
import { ClubModule } from './modules/club/club.module.js';
import { TeamModule } from './modules/team/team.module.js';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PrismaModule,
    FirebaseModule,
    IdentityModule,
    ClubModule,
    TeamModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
