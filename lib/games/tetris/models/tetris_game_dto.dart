class TetrisResultDto {
  final int finalScore;
  final int finalLevel;
  final int linesCleared;
  final int durationSeconds;

  TetrisResultDto({
    required this.finalScore,
    required this.finalLevel,
    required this.linesCleared,
    required this.durationSeconds,
  });

  Map<String, dynamic> toJson() {
    return {
      'finalScore': finalScore,
      'finalLevel': finalLevel,
      'linesCleared': linesCleared,
      'durationSeconds': durationSeconds,
    };
  }
}