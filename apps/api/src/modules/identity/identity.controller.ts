import { Controller, Get, UseGuards } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOkResponse,
  ApiOperation,
  ApiServiceUnavailableResponse,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import { CurrentFirebaseIdentity } from '../../infrastructure/firebase/current-firebase-identity.decorator.js';
import { FirebaseAuthGuard } from '../../infrastructure/firebase/firebase-auth.guard.js';
import type { FirebaseIdentity } from '../../infrastructure/firebase/firebase-identity.js';

@ApiTags('identity')
@Controller('identity')
export class IdentityController {
  @Get('me')
  @UseGuards(FirebaseAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Return the authenticated Firebase identity' })
  @ApiOkResponse({
    schema: {
      example: {
        firebaseUid: 'firebase-user-id',
        email: 'coach@example.com',
        displayName: 'Coach',
      },
    },
  })
  @ApiUnauthorizedResponse({ description: 'Missing or invalid Firebase token' })
  @ApiServiceUnavailableResponse({
    description: 'Firebase Admin is not configured on the server',
  })
  getCurrentIdentity(
    @CurrentFirebaseIdentity() identity: FirebaseIdentity,
  ): FirebaseIdentity {
    return identity;
  }
}
