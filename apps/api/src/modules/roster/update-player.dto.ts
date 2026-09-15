import { ApiPropertyOptional } from '@nestjs/swagger';
import { DominantFoot, PlayerPosition } from '../../generated/prisma/enums.js';

export class UpdatePlayerDto {
  @ApiPropertyOptional({ example: 'Amine' })
  firstName?: string;

  @ApiPropertyOptional({ example: 'Benali' })
  lastName?: string;

  @ApiPropertyOptional({ enum: PlayerPosition, example: PlayerPosition.PIVOT })
  primaryPosition?: PlayerPosition;

  @ApiPropertyOptional({
    enum: PlayerPosition,
    example: PlayerPosition.WINGER,
    nullable: true,
  })
  secondaryPosition?: PlayerPosition | null;

  @ApiPropertyOptional({ example: 10, nullable: true })
  shirtNumber?: number | null;

  @ApiPropertyOptional({
    enum: DominantFoot,
    example: DominantFoot.RIGHT,
    nullable: true,
  })
  dominantFoot?: DominantFoot | null;

  @ApiPropertyOptional({ example: false })
  active?: boolean;
}
