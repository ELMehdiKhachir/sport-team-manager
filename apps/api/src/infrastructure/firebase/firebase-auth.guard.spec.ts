import {
  ExecutionContext,
  ServiceUnavailableException,
  UnauthorizedException,
} from '@nestjs/common';
import type { Request } from 'express';
import { FirebaseAuthGuard } from './firebase-auth.guard.js';
import type { FirebaseAdminService } from './firebase-admin.service.js';

describe('FirebaseAuthGuard', () => {
  const verifyIdToken = vi.fn();
  const firebaseAdmin = {
    isConfigured: vi.fn(() => true),
    getAuth: vi.fn(() => ({ verifyIdToken })),
  } as unknown as FirebaseAdminService;

  beforeEach(() => {
    vi.clearAllMocks();
    vi.mocked(firebaseAdmin.isConfigured).mockReturnValue(true);
  });

  it('attaches the verified identity to the request', async () => {
    const request = createRequest('Bearer valid-token');
    verifyIdToken.mockResolvedValueOnce({
      uid: 'user-1',
      email: 'coach@example.com',
      name: 'Coach',
    });

    const guard = new FirebaseAuthGuard(firebaseAdmin);

    await expect(guard.canActivate(createContext(request))).resolves.toBe(true);
    expect(verifyIdToken).toHaveBeenCalledWith('valid-token');
    expect(request.firebaseIdentity).toEqual({
      firebaseUid: 'user-1',
      email: 'coach@example.com',
      displayName: 'Coach',
    });
  });

  it('rejects a request without a bearer token', async () => {
    const guard = new FirebaseAuthGuard(firebaseAdmin);

    await expect(
      guard.canActivate(createContext(createRequest())),
    ).rejects.toBeInstanceOf(UnauthorizedException);
  });

  it('rejects an invalid token', async () => {
    verifyIdToken.mockRejectedValueOnce(new Error('invalid token'));
    const guard = new FirebaseAuthGuard(firebaseAdmin);

    await expect(
      guard.canActivate(createContext(createRequest('Bearer invalid-token'))),
    ).rejects.toBeInstanceOf(UnauthorizedException);
  });

  it('reports missing server configuration', async () => {
    vi.mocked(firebaseAdmin.isConfigured).mockReturnValue(false);
    const guard = new FirebaseAuthGuard(firebaseAdmin);

    await expect(
      guard.canActivate(createContext(createRequest('Bearer token'))),
    ).rejects.toBeInstanceOf(ServiceUnavailableException);
    expect(verifyIdToken).not.toHaveBeenCalled();
  });
});

type TestRequest = Request & {
  firebaseIdentity?: {
    firebaseUid: string;
    email?: string;
    displayName?: string;
  };
};

function createRequest(authorization?: string): TestRequest {
  return {
    headers: authorization ? { authorization } : {},
  } as TestRequest;
}

function createContext(request: TestRequest): ExecutionContext {
  return {
    switchToHttp: () => ({
      getRequest: () => request,
    }),
  } as ExecutionContext;
}
