class ServerIdentity {
  const ServerIdentity({
    required this.firebaseUid,
    this.email,
    this.displayName,
  });

  final String firebaseUid;
  final String? email;
  final String? displayName;
}

abstract interface class IdentityGateway {
  Future<ServerIdentity> getCurrentIdentity();
}
