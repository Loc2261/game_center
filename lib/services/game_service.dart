import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/caro_model.dart';
import '../models/game_model.dart';
import 'storage_service.dart';

class GameService {
  final String baseUrl;
  final StorageService storageService;

  GameService({required this.baseUrl, required this.storageService});

  Future<CaroGame> startCaroGame(String difficulty) async {
    final token = await storageService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/api/games/caro/start?difficulty=$difficulty'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return CaroGame.fromJson(jsonResponse['data']);
    } else {
      throw Exception('Failed to start game: ${response.statusCode}');
    }
  }

  Future<CaroGame> makeCaroMove(CaroMove move) async {
    final token = await storageService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/api/games/caro/move'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(move.toJson()),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return CaroGame.fromJson(jsonResponse['data']);
    } else {
      throw Exception('Failed to make move: ${response.statusCode}');
    }
  }

  Future<GameResult> submitGameCompletion(GameCompleteRequest request) async {
    final token = await storageService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/api/games/complete'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return GameResult.fromJson(jsonResponse['data']);
    } else {
      throw Exception('Failed to submit game completion: ${response.statusCode}');
    }
  }

  Future<List<GameResult>> getUserGameHistory({String? gameType}) async {
    final token = await storageService.getToken();
    final url = gameType != null
        ? '$baseUrl/api/games/history?gameType=$gameType'
        : '$baseUrl/api/games/history';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['data'];
      return data.map((item) => GameResult.fromJson(item)).toList();
    } else {
      throw Exception('Failed to get game history: ${response.statusCode}');
    }
  }

  Future<GameStats> getUserGameStats(String gameType) async {
    final token = await storageService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/games/stats/$gameType'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return GameStats.fromJson(jsonResponse['data']);
    } else {
      throw Exception('Failed to get game stats: ${response.statusCode}');
    }
  }

  Future<List<LeaderboardEntry>> getGameLeaderboard(String gameType, {int top = 10}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/games/leaderboard/$gameType?top=$top'),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['data'];
      return data.map((item) => LeaderboardEntry.fromJson(item)).toList();
    } else {
      throw Exception('Failed to get leaderboard: ${response.statusCode}');
    }
  }

  Future<List<LeaderboardEntry>> getGlobalLeaderboard({int top = 10}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/games/leaderboard/global?top=$top'),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['data'];
      return data.map((item) => LeaderboardEntry.fromJson(item)).toList();
    } else {
      throw Exception('Failed to get global leaderboard: ${response.statusCode}');
    }
  }
}