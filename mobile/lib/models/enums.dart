/// Enum representing game difficulty levels
enum Difficulty {
  easy('Easy'),
  medium('Medium'),
  hard('Hard'),
  expert('Expert');

  final String displayName;
  const Difficulty(this.displayName);

  static Difficulty fromString(String value) {
    return Difficulty.values.firstWhere(
      (d) => d.displayName == value,
      orElse: () => Difficulty.medium,
    );
  }
}

/// Enum representing game themes
enum GameTheme {
  dark('Dark'),
  light('Light'),
  neon('Neon'),
  retro('Retro');

  final String displayName;
  const GameTheme(this.displayName);

  static GameTheme fromString(String value) {
    return GameTheme.values.firstWhere(
      (t) => t.displayName == value,
      orElse: () => GameTheme.dark,
    );
  }
}
