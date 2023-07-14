enum GameOverStatus {
  won("You have won!"),
  lost("You have lost!"),
  surrendered("Player has surrendered!");

  const GameOverStatus(this.value);

  final String value;
}
