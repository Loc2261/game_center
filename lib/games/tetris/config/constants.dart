class GameConstants {
  // Board dimensions
  static const int boardWidth = 10;
  static const int boardHeight = 20;
  static const int bufferZone = 4;
  static const int totalHeight = boardHeight + bufferZone;

  // Scoring
  static const int softDropPoints = 1;
  static const int hardDropPoints = 2;
  static const Map<int, int> lineClearPoints = {
    1: 100,  // Single
    2: 300,  // Double
    3: 500,  // Triple
    4: 800,  // Tetris
  };

  // Timing (milliseconds)
  static const int baseGravitySpeed = 1000;
  static const int minGravitySpeed = 100;
  static const int levelSpeedDecrease = 50;

  // Input settings
  static const int dasDelay = 170; // Delayed Auto Shift (ms)
  static const int arrDelay = 33;  // Auto Repeat Rate (ms)
  static const int lockDelay = 500; // Lock delay (ms)

  // Lines per level
  static const int linesPerLevel = 5;

  static int getGravitySpeed(int level) {
    final speed = baseGravitySpeed - (level * levelSpeedDecrease);
    return speed < minGravitySpeed ? minGravitySpeed : speed;
  }

  static int getLevel(int linesCleared) {
    return (linesCleared ~/ linesPerLevel) + 1;
  }
}