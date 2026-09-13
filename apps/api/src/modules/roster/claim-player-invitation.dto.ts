import { ApiProperty } from '@nestjs/swagger';
import { IsString, MinLength } from 'class-validator';

export class ClaimPlayerInvitationDto {
  @ApiProperty({ description: 'Opaque invitation token' })
  @IsString()
  @MinLength(20)
  token!: string;
}
