enum PlayerPosition {
  goalkeeper('GOALKEEPER', 'Gardien'),
  fixo('FIXO', 'Fixo'),
  winger('WINGER', 'Ailier'),
  pivot('PIVOT', 'Pivot');

  const PlayerPosition(this.apiValue, this.label);
  final String apiValue;
  final String label;

  static PlayerPosition fromApi(String value) => values.firstWhere(
        (position) => position.apiValue == value,
        orElse: () => throw ArgumentError('Unknown player position: $value'),
      );
}

enum DominantFoot {
  right('RIGHT', 'Droit'),
  left('LEFT', 'Gauche'),
  both('BOTH', 'Les deux');

  const DominantFoot(this.apiValue, this.label);
  final String apiValue;
  final String label;

  static DominantFoot fromApi(String value) => values.firstWhere(
        (foot) => foot.apiValue == value,
        orElse: () => throw ArgumentError('Unknown dominant foot: $value'),
      );
}

class PlayerSummary {
  const PlayerSummary({
    required this.id,
    required this.teamId,
    required this.firstName,
    required this.lastName,
    required this.primaryPosition,
    required this.accountAssociated,
    this.secondaryPosition,
    this.shirtNumber,
    this.dominantFoot,
  });

  final String id;
  final String teamId;
  final String firstName;
  final String lastName;
  final PlayerPosition primaryPosition;
  final PlayerPosition? secondaryPosition;
  final int? shirtNumber;
  final DominantFoot? dominantFoot;
  final bool accountAssociated;

  String get displayName => '$firstName $lastName';
}

class PlayerInvitation {
  const PlayerInvitation({required this.token, required this.expiresAt});

  final String token;
  final DateTime expiresAt;
}

abstract interface class PlayerGateway {
  Future<List<PlayerSummary>> listPlayers(String teamId);

  Future<PlayerSummary> createPlayer({
    required String teamId,
    required String firstName,
    required String lastName,
    required PlayerPosition primaryPosition,
    PlayerPosition? secondaryPosition,
    int? shirtNumber,
    DominantFoot? dominantFoot,
  });

  Future<PlayerSummary> updatePlayer({
    required String teamId,
    required String playerId,
    required String firstName,
    required String lastName,
    required PlayerPosition primaryPosition,
    PlayerPosition? secondaryPosition,
    int? shirtNumber,
    DominantFoot? dominantFoot,
  });

  Future<PlayerInvitation> createInvitation({
    required String teamId,
    required String playerId,
  });

  Future<PlayerSummary> claimInvitation(String token);
}
