import { Test, TestingModule } from '@nestjs/testing';
import { AppController } from './app.controller.js';
import { AppService } from './app.service.js';
import { PrismaService } from './infrastructure/prisma/prisma.service.js';

describe('AppController', () => {
  let appController: AppController;
  const queryRaw = vi.fn();

  beforeEach(async () => {
    const app: TestingModule = await Test.createTestingModule({
      controllers: [AppController],
      providers: [
        AppService,
        {
          provide: PrismaService,
          useValue: { $queryRaw: queryRaw },
        },
      ],
    }).compile();

    appController = app.get<AppController>(AppController);
  });

  describe('health', () => {
    it('returns the service status', () => {
      expect(appController.getHealth()).toEqual({
        status: 'ok',
        service: 'sport-team-manager-api',
      });
    });

    it('returns the database status after a successful query', async () => {
      queryRaw.mockResolvedValueOnce([{ '?column?': 1 }]);

      await expect(appController.getDatabaseHealth()).resolves.toEqual({
        status: 'ok',
        database: 'reachable',
      });
      expect(queryRaw).toHaveBeenCalledOnce();
    });
  });
});
