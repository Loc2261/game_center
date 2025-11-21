import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/caro_model.dart';
import '../models/game_model.dart';
import '../services/api_service.dart';

class GameProvider with ChangeNotifier {
  final ApiService _apiService;

  GameProvider({required ApiService apiService}) : _apiService = apiService;

  // Caro Game State
  CaroGame? _currentCaroGame;
  bool _isLoading = false;
  String _error = '';

  CaroGame? get currentCaroGame => _currentCaroGame;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Game History & Leaderboard
  List<GameResult> _gameHistory = [];
  List<LeaderboardEntry> _leaderboard = [];
  GameStats? _gameStats;

  List<GameResult> get gameHistory => _gameHistory;
  List<LeaderboardEntry> get leaderboard => _leaderboard;
  GameStats? get gameStats => _gameStats;

  // Caro Game Methods
  Future<void> startNewCaroGame(String difficulty) async {
    _setLoading(true);
    _error = '';

    try {
      final response = await ApiService.post('/games/caro/start?difficulty=$difficulty', null);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        _currentCaroGame = CaroGame.fromJson(jsonResponse['data']);
        notifyListeners();
      } else {
        throw Exception('Failed to start game: ${response.statusCode}');
      }
    } catch (e) {
      _error = 'Failed to start game: $e';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> makeCaroMove(int row, int col) async {
    if (_currentCaroGame == null || _isLoading) return;

    _setLoading(true);
    _error = '';

    try {
      final move = CaroMove(
        gameId: _currentCaroGame!.gameId,
        row: row,
        col: col,
      );

      final response = await ApiService.post('/games/caro/move', move.toJson());
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        _currentCaroGame = CaroGame.fromJson(jsonResponse['data']);
        notifyListeners();

        // If game is over, submit the result
        if (_currentCaroGame!.isGameOver) {
          await _submitCaroGameResult();
        }
      } else {
        throw Exception('Failed to make move: ${response.statusCode}');
      }
    } catch (e) {
      _error = 'Failed to make move: $e';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _submitCaroGameResult() async {
    if (_currentCaroGame == null) return;

    final playerMoves = _currentCaroGame!.moveHistory
        .where((move) => _getCellValue(move.row, move.col) == 'X')
        .length;

    final computerMoves = _currentCaroGame!.moveHistory
        .where((move) => _getCellValue(move.row, move.col) == 'O')
        .length;

    final result = CaroGameResult(
      difficulty: _currentCaroGame!.difficulty,
      isWin: _currentCaroGame!.winner == 'X',
      totalMoves: _currentCaroGame!.moveHistory.length,
      playerMoves: playerMoves,
      computerMoves: computerMoves,
      mistakes: 0, // You can implement mistake tracking logic
      completionTime: Duration(minutes: _currentCaroGame!.moveHistory.length ~/ 2),
      gameId: _currentCaroGame!.gameId,
    );

    final request = GameCompleteRequest(
      gameType: 'Caro',
      caroResult: result,
    );

    try {
      final response = await ApiService.post('/games/complete', request.toJson());
      if (response.statusCode == 200) {
        // Refresh stats and history
        await loadGameHistory();
        await loadGameStats();
      } else {
        throw Exception('Failed to submit game result: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to submit game result: $e');
    }
  }

  Future<void> saveCurrentGame() async {
    if (_currentCaroGame == null || !_currentCaroGame!.isGameOver) return;

    try {
      final playerMoves = _currentCaroGame!.moveHistory
          .where((move) => _getCellValue(move.row, move.col) == 'X')
          .length;

      final computerMoves = _currentCaroGame!.moveHistory
          .where((move) => _getCellValue(move.row, move.col) == 'O')
          .length;

      final result = CaroGameResult(
        difficulty: _currentCaroGame!.difficulty,
        isWin: _currentCaroGame!.winner == 'X',
        totalMoves: _currentCaroGame!.moveHistory.length,
        playerMoves: playerMoves,
        computerMoves: computerMoves,
        mistakes: 0,
        completionTime: Duration(minutes: _currentCaroGame!.moveHistory.length ~/ 2),
        gameId: _currentCaroGame!.gameId,
      );

      final request = GameCompleteRequest(
        gameType: 'Caro',
        caroResult: result,
      );

      await ApiService.post('/games/complete', request.toJson());

      // Refresh data after saving
      await loadGameHistory();
      await loadGameStats();

    } catch (e) {
      _error = 'Failed to save game: $e';
      notifyListeners();
      rethrow;
    }
  }

  String _getCellValue(int row, int col) {
    if (_currentCaroGame == null || row >= _currentCaroGame!.board.length) {
      return ' ';
    }
    final rowString = _currentCaroGame!.board[row];
    return col < rowString.length ? rowString[col] : ' ';
  }

  Future<void> loadGameStats({String gameType = 'Caro'}) async {
    _setLoading(true);
    try {
      final response = await ApiService.get('/games/stats/$gameType');
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        _gameStats = GameStats.fromJson(jsonResponse['data']);
        notifyListeners();
      } else {
        throw Exception('Failed to load game stats: ${response.statusCode}');
      }
    } catch (e) {
      _error = 'Failed to load game stats: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadGameHistory({String? gameType}) async {
    _setLoading(true);
    _error = '';

    try {
      final endpoint = gameType != null
          ? '/games/history?gameType=$gameType'
          : '/games/history';
      final response = await ApiService.get(endpoint);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        _gameHistory = data.map((item) => GameResult.fromJson(item)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load game history: ${response.statusCode}');
      }
    } catch (e) {
      _error = 'Failed to load game history: $e';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadLeaderboard({required String gameType, int top = 10}) async {
    _setLoading(true);
    _error = '';

    try {
      final response = await ApiService.get('/games/leaderboard/$gameType?top=$top');
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        _leaderboard = data.map((item) => LeaderboardEntry.fromJson(item)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load leaderboard: ${response.statusCode}');
      }
    } catch (e) {
      _error = 'Failed to load leaderboard: $e';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadGlobalLeaderboard({int top = 10}) async {
    _setLoading(true);
    _error = '';

    try {
      final response = await ApiService.get('/games/leaderboard/global?top=$top');
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        _leaderboard = data.map((item) => LeaderboardEntry.fromJson(item)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load global leaderboard: ${response.statusCode}');
      }
    } catch (e) {
      _error = 'Failed to load global leaderboard: $e';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  Future<void> submitGameCompletion(GameCompleteRequest request) async {
    _setLoading(true);
    _error = '';
    notifyListeners();

    try {
      final response = await ApiService.post('/games/complete', request.toJson());
      if (response.statusCode == 200) {
        // Successfully submitted, now refresh user's history and stats
        await loadGameHistory();
        await loadGameStats(gameType: request.gameType);
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to submit game result');
      }
    } catch (e) {
      _error = 'Error submitting score: $e';
      rethrow; // Rethrow to let the UI know about the failure
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  void resetGame() {
    _currentCaroGame = null;
    _error = '';
    notifyListeners();
  }
}