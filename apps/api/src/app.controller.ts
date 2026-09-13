import { Controller, Get } from '@nestjs/common';
import { ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { AppService } from './app.service.js';
import { PrismaService } from './infrastructure/prisma/prisma.service.js';

@ApiTags('system')
@Controller('health')
export class AppController {
  constructor(
    private readonly appService: AppService,
    private readonly prisma: PrismaService,
  ) {}

  @Get()
  @ApiOperation({ summary: 'Check API health' })
  @ApiOkResponse({
    schema: {
      example: { status: 'ok', service: 'sport-team-manager-api' },
    },
  })
  getHealth(): { status: 'ok'; service: string } {
    return this.appService.getHealth();
  }

  @Get('database')
  @ApiOperation({ summary: 'Check database connectivity' })
  @ApiOkResponse({
    schema: {
      example: { status: 'ok', database: 'reachable' },
    },
  })
  async getDatabaseHealth(): Promise<{
    status: 'ok';
    database: 'reachable';
  }> {
    await this.prisma.$queryRaw`SELECT 1`;
    return { status: 'ok', database: 'reachable' };
  }
}
