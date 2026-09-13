import {
  ConflictException,
  ForbiddenException,
  Inject,
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { createHash, randomBytes } from 'node:crypto';
import { TeamRole } from '../../generated/prisma/enums.js';
import type { FirebaseIdentity } from '../../infrastructure/firebase/firebase-identity.js';
import {
  ROSTER_REPOSITORY,
  RosterRepository,
  type PlayerSummary,
} from './roster.repository.js';

const INVITE_TTL_MS = 7 * 24 * 60 * 60 * 1000;

function hashToken(token: string): string {
  return createHash('sha256').update(token).digest('hex');
}

@Injectable()
export class CreatePlayerInvitationService {
  constructor(
    @Inject(ROSTER_REPOSITORY)
    private readonly rosterRepository: RosterRepository,
  ) {}

  async execute(firebaseUid: string, teamId: string, playerId: string) {
    const roles = await this.rosterRepository.getMembershipRoles(
      firebaseUid,
      teamId,
    );
    const canManage =
      roles?.includes(TeamRole.OWNER_MANAGER) || roles?.includes(TeamRole.COACH);
    if (!canManage) {
      throw new ForbiddenException('Roster management is not allowed');
    }

    const player = await this.rosterRepository.findById(teamId, playerId);
    if (!player) throw new NotFoundException('Player profile not found');
    if (player.accountAssociated) {
      throw new ConflictException('This player profile is already associated');
    }

    const token = randomBytes(32).toString('base64url');
    const expiresAt = new Date(Date.now() + INVITE_TTL_MS);
    await this.rosterRepository.saveInvite(
      player.id,
      hashToken(token),
      expiresAt,
    );

    return { token, expiresAt: expiresAt.toISOString() };
  }
}

@Injectable()
export class ClaimPlayerInvitationService {
  constructor(
    @Inject(ROSTER_REPOSITORY)
    private readonly rosterRepository: RosterRepository,
  ) {}

  async execute(identity: FirebaseIdentity, token: string): Promise<PlayerSummary> {
    const normalized = token?.trim();
    if (!normalized || normalized.length < 20) {
      throw new UnauthorizedException('Invitation token is invalid');
    }

    const player = await this.rosterRepository.claimInvite({
      tokenHash: hashToken(normalized),
      now: new Date(),
      firebaseUid: identity.firebaseUid,
      email: identity.email,
      displayName: identity.displayName,
    });

    if (!player) {
      throw new UnauthorizedException('Invitation is invalid, expired or already used');
    }
    return player;
  }
}
