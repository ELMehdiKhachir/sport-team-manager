import {
  CanActivate,
  ExecutionContext,
  Injectable,
  ServiceUnavailableException,
  UnauthorizedException,
} from '@nestjs/common';
import type { Request } from 'express';
import { FirebaseAdminService } from './firebase-admin.service.js';
import type { FirebaseIdentity } from './firebase-identity.js';

export interface FirebaseAuthenticatedRequest extends Request {
  firebaseIdentity: FirebaseIdentity;
}

@Injectable()
export class FirebaseAuthGuard implements CanActivate {
  constructor(private readonly firebaseAdmin: FirebaseAdminService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    if (!this.firebaseAdmin.isConfigured()) {
      throw new ServiceUnavailableException(
        'Firebase Admin is not configured on the server',
      );
    }

    const request = context
      .switchToHttp()
      .getRequest<FirebaseAuthenticatedRequest>();
    const token = this.extractBearerToken(request.headers.authorization);

    if (!token) {
      throw new UnauthorizedException('Missing Firebase bearer token');
    }

    try {
      const decodedToken = await this.firebaseAdmin
        .getAuth()
        .verifyIdToken(token);

      request.firebaseIdentity = {
        firebaseUid: decodedToken.uid,
        ...(decodedToken.email ? { email: decodedToken.email } : {}),
        ...(decodedToken.name ? { displayName: decodedToken.name } : {}),
      };
      return true;
    } catch {
      throw new UnauthorizedException(
        'Invalid or expired Firebase bearer token',
      );
    }
  }

  private extractBearerToken(authorization?: string): string | null {
    if (!authorization) return null;

    const [scheme, token, extra] = authorization.trim().split(/\s+/);
    if (scheme?.toLowerCase() !== 'bearer' || !token || extra) return null;

    return token;
  }
}
