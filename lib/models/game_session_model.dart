
class GameSession {
  final String id;
  final String gameType;
  final int score;
  final DateTime playedAt;
  final Duration duration;
  final bool isWin;
  final Map<String, dynamic>? gameData;

  GameSession({
    required this.id,
    required this.gameType,
    required this.score,
    required this.playedAt,
    required this.duration,
    required this.isWin,
    this.gameData,
  });

  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      id: json['id']?.toString() ?? '',
      gameType: json['gameType']?.toString() ?? 'unknown',
      score: (json['score'] as num?)?.toInt() ?? 0,
      playedAt: DateTime.parse(json['playedAt']?.toString() ?? DateTime.now().toIso8601String()),
      duration: Duration(seconds: (json['duration'] as num?)?.toInt() ?? 0),
      isWin: json['isWin'] == true,
      gameData: json['gameData'] is Map ? Map<String, dynamic>.from(json['gameData']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gameType': gameType,
      'score': score,
      'playedAt': playedAt.toIso8601String(),
      'duration': duration.inSeconds,
      'isWin': isWin,
      if (gameData != null) 'gameData': gameData,
    };
  }

  @override
  String toString() {
    return 'GameSession(id: $id, gameType: $gameType, score: $score, isWin: $isWin)';
  }
}