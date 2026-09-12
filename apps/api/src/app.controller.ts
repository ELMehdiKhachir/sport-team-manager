import { Controller, Get } from '@nestjs/common';
import { ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { AppService } from './app.service.js';

@ApiTags('system')
@Controller('health')
export class AppController {
  constructor(private readonly appService: AppService) {}

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
}
