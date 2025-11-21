import 'package:flutter/material.dart';
import '../services/leaderboard_api_service.dart';
import '../models/leaderboard_model.dart';
import '../models/game_session_model.dart';

class LeaderboardProvider with ChangeNotifier {
  final LeaderboardApiService _apiService;

  List<LeaderboardEntry> _gameLeaderboard = [];
  List<LeaderboardEntry> _globalLeaderboard = [];
  List<GameSession> _myGameHistory = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<LeaderboardEntry> get gameLeaderboard => _gameLeaderboard;
  List<LeaderboardEntry> get globalLeaderboard => _globalLeaderboard;
  List<GameSession> get myGameHistory => _myGameHistory;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  LeaderboardProvider(this._apiService);

  Future<void> _execute(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await action();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      print('LeaderboardProvider error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchGameLeaderboard(String gameType, {int top = 10}) async {
    await _execute(() async {
      final leaderboard = await _apiService.getGameLeaderboard(gameType, top: top);
      _gameLeaderboard = leaderboard;
    });
  }

  Future<void> fetchGlobalLeaderboard({int top = 10}) async {
    await _execute(() async {
      final leaderboard = await _apiService.getGlobalLeaderboard(top: top);
      _globalLeaderboard = leaderboard;
    });
  }

  Future<void> fetchMyGameHistory({String? gameType}) async {
    await _execute(() async {
      final history = await _apiService.getMyGameHistory(gameType: gameType);
      _myGameHistory = history;
    });
  }

  Future<Map<String, dynamic>> getUserGameStats(String gameType) async {
    try {
      return await _apiService.getUserGameStats(gameType);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  void clearLeaderboard() {
    _gameLeaderboard = [];
    _globalLeaderboard = [];
    notifyListeners();
  }

  void clearHistory() {
    _myGameHistory = [];
    notifyListeners();
  }
}