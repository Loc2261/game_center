class Position {
  final int x;
  final int y;

  const Position(this.x, this.y);

  Position operator +(Position other) => Position(x + other.x, y + other.y);
  Position operator -(Position other) => Position(x - other.x, y - other.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position && x == other.x && y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  @override
  String toString() => 'Position($x, $y)';
}