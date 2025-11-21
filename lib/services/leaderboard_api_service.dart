import 'dart:convert';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../models/leaderboard_model.dart';
import '../models/game_session_model.dart';

class LeaderboardApiService {
  Future<List<LeaderboardEntry>> getGameLeaderboard(String gameType, {int top = 10}) async {
    try {
      final response = await ApiService.get('/games/leaderboard/$gameType?top=$top');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> leaderboardData = data['data'] ?? [];

          if (leaderboardData.isEmpty) {
            return [];
          }

          return leaderboardData.map((item) {
            try {
              return LeaderboardEntry.fromJson(item);
            } catch (e) {
              print('Error parsing leaderboard entry: $e');
              return LeaderboardEntry(
                rank: 0,
                user: User.fromJson({}),
                totalScore: 0,
                gamesPlayed: 0,
                gamesWon: 0,
                winRate: 0.0,
              );
            }
          }).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load leaderboard');
        }
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error in getGameLeaderboard: $e');
      return [];
    }
  }

  Future<List<LeaderboardEntry>> getGlobalLeaderboard({int top = 10}) async {
    try {
      final response = await ApiService.get('/games/leaderboard/global?top=$top');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> leaderboardData = data['data'] ?? [];

          if (leaderboardData.isEmpty) {
            return [];
          }

          return leaderboardData.map((item) {
            try {
              return LeaderboardEntry.fromJson(item);
            } catch (e) {
              print('Error parsing global leaderboard entry: $e');
              return LeaderboardEntry(
                rank: 0,
                user: User.fromJson({}),
                totalScore: 0,
                gamesPlayed: 0,
                gamesWon: 0,
                winRate: 0.0,
              );
            }
          }).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load global leaderboard');
        }
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error in getGlobalLeaderboard: $e');
      return [];
    }
  }

  Future<List<GameSession>> getMyGameHistory({String? gameType}) async {
    try {
      final String endpoint = gameType != null
          ? '/games/history?gameType=$gameType'
          : '/games/history';

      final response = await ApiService.get(endpoint);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> historyData = data['data'] ?? [];

          if (historyData.isEmpty) {
            return [];
          }

          return historyData.map((item) {
            try {
              return GameSession.fromJson(item);
            } catch (e) {
              print('Error parsing game history: $e');
              return GameSession(
                id: '',
                gameType: gameType ?? 'unknown',
                score: 0,
                duration: Duration.zero,
                playedAt: DateTime.now(),
                isWin: false,
              );
            }
          }).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load game history');
        }
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error in getMyGameHistory: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getUserGameStats(String gameType) async {
    try {
      final response = await ApiService.get('/games/stats/$gameType');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'] ?? {};
        } else {
          throw Exception(data['message'] ?? 'Failed to load user stats');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error in getUserGameStats: $e');
      return {};
    }
  }
}