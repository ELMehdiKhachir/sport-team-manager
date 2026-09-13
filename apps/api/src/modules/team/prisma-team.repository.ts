import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../infrastructure/prisma/prisma.service.js';
import { TeamRepository } from './team.repository.js';
import type { TeamSummary } from './team-summary.js';

@Injectable()
export class PrismaTeamRepository implements TeamRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findByFirebaseUid(firebaseUid: string): Promise<TeamSummary[]> {
    const memberships = await this.prisma.teamMembership.findMany({
      where: { user: { firebaseUid } },
      include: { team: { include: { club: true } } },
      orderBy: { createdAt: 'asc' },
    });

    return memberships.map(({ team, roles }) => ({
      id: team.id,
      name: team.name,
      club: team.club ? { id: team.club.id, name: team.club.name } : null,
      roles,
    }));
  }
}
