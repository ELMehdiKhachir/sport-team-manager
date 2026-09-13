import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import type { FirebaseAuthenticatedRequest } from './firebase-auth.guard.js';

export const CurrentFirebaseIdentity = createParamDecorator(
  (_data: unknown, context: ExecutionContext) =>
    context.switchToHttp().getRequest<FirebaseAuthenticatedRequest>()
      .firebaseIdentity,
);
