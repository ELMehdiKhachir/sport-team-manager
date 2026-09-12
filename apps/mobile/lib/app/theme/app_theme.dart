import 'package:flutter/material.dart';

@immutable
class ClubPalette {
  const ClubPalette({
    required this.primary,
    this.secondary,
    this.accent,
  });

  final Color primary;
  final Color? secondary;
  final Color? accent;
}

@immutable
class FunctionalColors extends ThemeExtension<FunctionalColors> {
  const FunctionalColors({
    required this.success,
    required this.warning,
    required this.info,
    required this.yellowCard,
    required this.redCard,
  });

  final Color success;
  final Color warning;
  final Color info;
  final Color yellowCard;
  final Color redCard;

  @override
  FunctionalColors copyWith({
    Color? success,
    Color? warning,
    Color? info,
    Color? yellowCard,
    Color? redCard,
  }) => FunctionalColors(
    success: success ?? this.success,
    warning: warning ?? this.warning,
    info: info ?? this.info,
    yellowCard: yellowCard ?? this.yellowCard,
    redCard: redCard ?? this.redCard,
  );

  @override
  FunctionalColors lerp(FunctionalColors? other, double t) {
    if (other == null) return this;
    return FunctionalColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      yellowCard: Color.lerp(yellowCard, other.yellowCard, t)!,
      redCard: Color.lerp(redCard, other.redCard, t)!,
    );
  }
}

abstract final class AppTheme {
  static ThemeData light(ClubPalette club) => _build(
    club,
    Brightness.light,
  );

  static ThemeData dark(ClubPalette club) => _build(
    club,
    Brightness.dark,
  );

  static ThemeData _build(ClubPalette club, Brightness brightness) {
    var scheme = ColorScheme.fromSeed(
      seedColor: club.primary,
      brightness: brightness,
    );

    scheme = scheme.copyWith(
      primary: club.primary,
      secondary: club.secondary,
      tertiary: club.accent,
    );

    final isDark = brightness == Brightness.dark;
    final functional = FunctionalColors(
      success: isDark ? const Color(0xFF72D49A) : const Color(0xFF167848),
      warning: isDark ? const Color(0xFFFFC866) : const Color(0xFF9A5A00),
      info: isDark ? const Color(0xFF7BCBFF) : const Color(0xFF00639A),
      yellowCard: const Color(0xFFFFD600),
      redCard: const Color(0xFFD32F2F),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      extensions: [functional],
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

extension SemanticColors on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  FunctionalColors get functionalColors =>
      Theme.of(this).extension<FunctionalColors>()!;
}

