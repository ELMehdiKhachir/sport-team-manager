import { ApiProperty } from '@nestjs/swagger';

export class CreateClubWithTeamDto {
  @ApiProperty({ example: 'Futsal Club de Lyon' })
  clubName: string;

  @ApiProperty({ example: 'Seniors 1' })
  teamName: string;
}
