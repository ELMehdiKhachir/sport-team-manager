import { ApiProperty } from '@nestjs/swagger';
import { TeamRole } from '../../generated/prisma/enums.js';

export class CreateTeamMemberInvitationDto {
  @ApiProperty({
    enum: [TeamRole.COACH, TeamRole.STAFF_ASSISTANT],
    example: TeamRole.COACH,
  })
  role: TeamRole;
}

export class ClaimTeamMemberInvitationDto {
  @ApiProperty({ description: 'Opaque invitation token' })
  token: string;
}
