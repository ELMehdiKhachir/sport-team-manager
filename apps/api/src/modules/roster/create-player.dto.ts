import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { DominantFoot, PlayerPosition } from '../../generated/prisma/enums.js';

export class CreatePlayerDto {
  @ApiProperty({ example: 'Amine' })
  firstName: string;

  @ApiProperty({ example: 'Benali' })
  lastName: string;

  @ApiProperty({ enum: PlayerPosition, example: PlayerPosition.PIVOT })
  primaryPosition: PlayerPosition;

  @ApiPropertyOptional({ enum: PlayerPosition, example: PlayerPosition.WINGER })
  secondaryPosition?: PlayerPosition;

  @ApiPropertyOptional({ example: 10 })
  shirtNumber?: number;

  @ApiPropertyOptional({ enum: DominantFoot, example: DominantFoot.RIGHT })
  dominantFoot?: DominantFoot;
}
