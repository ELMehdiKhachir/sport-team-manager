import { ApiProperty } from '@nestjs/swagger';

export class ClaimPlayerInvitationDto {
  @ApiProperty({ description: 'Opaque invitation token' })
  token: string;
}
