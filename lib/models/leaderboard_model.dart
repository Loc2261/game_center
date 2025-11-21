import 'package:flutter/foundation.dart';
import 'package:game_center/models/user_model.dart';

@immutable
class LeaderboardEntry {
  final int rank;
  final User user;
  final int totalScore;
  final int gamesPlayed;
  final int gamesWon;
  final double winRate;

  const LeaderboardEntry({
    required this.rank,
    required this.user,
    required this.totalScore,
    required this.gamesPlayed,
    required this.gamesWon,
    required this.winRate,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] as int? ?? 0,
      user: User.fromJson(json['user'] ?? {}),
      totalScore: json['totalScore'] as int? ?? 0,
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      gamesWon: json['gamesWon'] as int? ?? 0,
      winRate: (json['winRate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'user': user.toJson(),
      'totalScore': totalScore,
      'gamesPlayed': gamesPlayed,
      'gamesWon': gamesWon,
      'winRate': winRate,
    };
  }

  @override
  String toString() {
    return 'LeaderboardEntry(rank: $rank, user: ${user.username}, score: $totalScore)';
  }
}