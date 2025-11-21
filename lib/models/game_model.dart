import 'caro_model.dart';
import '../games/tetris/models/tetris_game_dto.dart';

class PuzzleResultDto {
  final String gameId;
  final String difficulty;
  final int gridSize;
  final int moves;
  final int durationSeconds;
  final String imageUrl;
  final bool isCompleted;

  PuzzleResultDto({
    required this.gameId,
    required this.difficulty,
    required this.gridSize,
    required this.moves,
    required this.durationSeconds,
    required this.imageUrl,
    required this.isCompleted,
  });

  Map<String, dynamic> toJson() {
    return {
      'gameId': gameId,
      'difficulty': difficulty,
      'gridSize': gridSize,
      'moves': moves,
      'durationSeconds': durationSeconds,
      'imageUrl': imageUrl,
      'isCompleted': isCompleted,
    };
  }
}

class GameScore {
  final String gameType;
  final int score;
  final int level;
  final int mistakes;
  final Duration completionTime;

  GameScore({
    required this.gameType,
    required this.score,
    this.level = 1,
    this.mistakes = 0,
    required this.completionTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'gameType': gameType,
      'score': score,
      'level': level,
      'mistakes': mistakes,
      'completionTime': completionTime.inSeconds,
    };
  }
}

class GameCompleteRequest {
  final String gameType;
  final CaroGameResult? caroResult;
  final TetrisResultDto? tetrisResult; 
  final PuzzleResultDto? puzzleResult;

  GameCompleteRequest({
    required this.gameType,
    this.caroResult,
    this.tetrisResult, 
    this.puzzleResult,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'gameType': gameType,
      // Use cascade operator to add non-null results
      if (caroResult != null) 'caroResult': caroResult!.toJson(),
      if (tetrisResult != null) 'tetrisResult': tetrisResult!.toJson(),
      if (puzzleResult != null) 'puzzleResult': puzzleResult!.toJson(),
    };
  }
}

class GameResult {
  final String id;
  final String userId;
  final String username;
  final String gameType;
  final int score;
  final int level;
  final int mistakes;
  final Duration completionTime;
  final DateTime playedAt;

  GameResult({
    required this.id,
    required this.userId,
    required this.username,
    required this.gameType,
    required this.score,
    required this.level,
    required this.mistakes,
    required this.completionTime,
    required this.playedAt,
  });

  factory GameResult.fromJson(Map<String, dynamic> json) {
    return GameResult(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      gameType: json['gameType'] ?? '',
      score: json['score'] ?? 0,
      level: json['level'] ?? 1,
      mistakes: json['mistakes'] ?? 0,
      completionTime: Duration(seconds: json['completionTime'] ?? 0),
      playedAt: DateTime.parse(json['playedAt']),
    );
  }
}

class GameStats {
  final String userId;
  final String gameType;
  final int totalGames;
  final int totalScore;
  final int averageScore;
  final int bestScore;
  final Duration averageCompletionTime;
  final Duration totalPlayTime;
  final DateTime lastPlayed;
  final int rank;

  GameStats({
    required this.userId,
    required this.gameType,
    required this.totalGames,
    required this.totalScore,
    required this.averageScore,
    required this.bestScore,
    required this.averageCompletionTime,
    required this.totalPlayTime,
    required this.lastPlayed,
    required this.rank,
  });

  factory GameStats.fromJson(Map<String, dynamic> json) {
    return GameStats(
      userId: json['userId'] ?? '',
      gameType: json['gameType'] ?? '',
      totalGames: json['totalGames'] ?? 0,
      totalScore: json['totalScore'] ?? 0,
      averageScore: json['averageScore'] ?? 0,
      bestScore: json['bestScore'] ?? 0,
      averageCompletionTime: Duration(seconds: json['averageCompletionTime'] ?? 0),
      totalPlayTime: Duration(seconds: json['totalPlayTime'] ?? 0),
      lastPlayed: DateTime.parse(json['lastPlayed']),
      rank: json['rank'] ?? 0,
    );
  }
}

class LeaderboardEntry {
  final int rank;
  final String userId;
  final String username;
  final int totalScore;
  final int gamesPlayed;
  final Duration averageCompletionTime;

  LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.username,
    required this.totalScore,
    required this.gamesPlayed,
    required this.averageCompletionTime,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] ?? 0,
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      totalScore: json['totalScore'] ?? 0,
      gamesPlayed: json['gamesPlayed'] ?? 0,
      averageCompletionTime: Duration(seconds: json['averageCompletionTime'] ?? 0),
    );
  }
}