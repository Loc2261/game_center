import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/tetromino.dart'; 
import '../models/position.dart';   
import '../config/constants.dart'; 
import '../config/srs_data.dart';    

class GameController extends ChangeNotifier {
  GameState _state = GameState.initial();
  Timer? _gravityTimer;
  Timer? _lockTimer;
  final Random _random = Random();

  // Input handling
  Timer? _dasTimer;
  Timer? _arrTimer;
  int _moveDirection = 0; // -1 left, 1 right, 0 none

  GameState get state => _state;

  void startGame() {
    _state = GameState.initial().copyWith(
      status: GameStatus.playing,
      nextQueue: _generateQueue(),
    );
    _spawnNextPiece();
    _startGravityTimer();
    notifyListeners();
  }

  void pauseGame() {
    if (_state.status == GameStatus.playing) {
      _state = _state.copyWith(status: GameStatus.paused);
      _stopTimers();
      notifyListeners();
    }
  }

  void resumeGame() {
    if (_state.status == GameStatus.paused) {
      _state = _state.copyWith(status: GameStatus.playing);
      _startGravityTimer();
      notifyListeners();
    }
  }
  
  void restartGame() {
    _stopTimers();
    startGame();
  }

  void quitGame(BuildContext context) {
    _stopTimers();
    // Instead of changing state, we pop the navigator to exit the game screen
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void moveLeft() {
    if (_state.status != GameStatus.playing) return;
    _movePiece(-1, 0);
  }

  void moveRight() {
    if (_state.status != GameStatus.playing) return;
    _movePiece(1, 0);
  }

  void startAutoMove(int direction) {
    _moveDirection = direction;
    _movePiece(direction, 0);
    
    _dasTimer?.cancel();
    _dasTimer = Timer(Duration(milliseconds: GameConstants.dasDelay), () {
      _arrTimer?.cancel();
      _arrTimer = Timer.periodic(
        Duration(milliseconds: GameConstants.arrDelay),
        (_) => _movePiece(_moveDirection, 0),
      );
    });
  }

  void stopAutoMove() {
    _moveDirection = 0;
    _dasTimer?.cancel();
    _arrTimer?.cancel();
  }

  void softDrop() {
    if (_state.status != GameStatus.playing) return;
    if (_movePiece(0, 1)) {
      _state = _state.copyWith(score: _state.score + GameConstants.softDropPoints);
      _resetLockTimer();
      notifyListeners();
    }
  }

  void hardDrop() {
    if (_state.status != GameStatus.playing || _state.currentPiece == null) return;
    
    int dropDistance = 0;
    while (_movePiece(0, 1)) {
      dropDistance++;
    }
    
    _state = _state.copyWith(
      score: _state.score + (dropDistance * GameConstants.hardDropPoints),
    );
    
    _lockPiece();
  }

  void rotateCW() {
    if (_state.status != GameStatus.playing) return;
    _rotate(true);
  }

  void rotateCCW() {
    if (_state.status != GameStatus.playing) return;
    _rotate(false);
  }

  void holdPiece() {
    if (_state.status != GameStatus.playing || !_state.canHold || _state.currentPiece == null) {
      return;
    }

    final currentType = _state.currentPiece!.type;
    
    if (_state.holdPiece == null) {
      _state = _state.copyWith(
        holdPiece: Tetromino.fromType(currentType),
        canHold: false,
        clearCurrentPiece: true,
      );
      _spawnNextPiece();
    } else {
      final heldType = _state.holdPiece!.type;
      _state = _state.copyWith(
        holdPiece: Tetromino.fromType(currentType),
        currentPiece: Tetromino.fromType(heldType),
        canHold: false,
      );
      _calculateGhostPiece();
    }
    
    notifyListeners();
  }

  bool _movePiece(int dx, int dy) {
    if (_state.currentPiece == null) return false;

    final newPiece = _state.currentPiece!.copyWith(
      position: Position(
        _state.currentPiece!.position.x + dx,
        _state.currentPiece!.position.y + dy,
      ),
    );

    if (_isValidPosition(newPiece)) {
      _state = _state.copyWith(currentPiece: newPiece);
      _calculateGhostPiece();
      notifyListeners();
      return true;
    }

    return false;
  }

  void _rotate(bool clockwise) {
    if (_state.currentPiece == null) return;

    final currentRotation = _state.currentPiece!.rotation;
    final rotatedPiece = _state.currentPiece!.rotate(clockwise);
    final newRotation = rotatedPiece.rotation;

    // Try wall kicks
    final kicks = SRSData.getWallKicks(
      _state.currentPiece!.type,
      currentRotation,
      newRotation,
    );

    for (final kick in kicks) {
      final testPiece = rotatedPiece.copyWith(
        position: Position(
          rotatedPiece.position.x + kick.x,
          rotatedPiece.position.y + kick.y,
        ),
      );

      if (_isValidPosition(testPiece)) {
        _state = _state.copyWith(currentPiece: testPiece);
        _calculateGhostPiece();
        _resetLockTimer();
        notifyListeners();
        return;
      }
    }
  }

  bool _isValidPosition(Tetromino piece) {
    for (final pos in piece.absolutePositions) {
      if (pos.x < 0 || 
          pos.x >= GameConstants.boardWidth || 
          pos.y >= GameConstants.totalHeight) {
        return false;
      }
      
      if (pos.y >= 0 && _state.board[pos.y][pos.x] != null) {
        return false;
      }
    }
    return true;
  }

  void _calculateGhostPiece() {
    if (_state.currentPiece == null) return;

    var ghostPiece = _state.currentPiece!;
    while (_isValidPosition(ghostPiece.moveDown())) {
      ghostPiece = ghostPiece.moveDown();
    }
    
    _state = _state.copyWith(ghostPieceY: ghostPiece.position.y);
  }

  void _spawnNextPiece() {
    if (_state.nextQueue.length < 3) {
      _state = _state.copyWith(
        nextQueue: [..._state.nextQueue, ..._generateQueue()],
      );
    }

    final nextType = _state.nextQueue.first;
    final newQueue = _state.nextQueue.sublist(1);
    final newPiece = Tetromino.fromType(nextType);

    if (!_isValidPosition(newPiece)) {
      _gameOver();
      return;
    }

    _state = _state.copyWith(
      currentPiece: newPiece,
      nextQueue: newQueue,
      canHold: true,
    );
    
    _calculateGhostPiece();
    _resetLockTimer();
    notifyListeners();
  }

  List<TetrominoType> _generateQueue() {
    final bag = List<TetrominoType>.from(TetrominoType.values);
    bag.shuffle(_random);
    return bag;
  }

  void _lockPiece() {
    if (_state.currentPiece == null) return;

    _lockTimer?.cancel();

    final newBoard = _state.board.map((row) => List<Color?>.from(row)).toList();
    
    for (final pos in _state.currentPiece!.absolutePositions) {
      if (pos.y >= 0 && pos.y < GameConstants.totalHeight) {
        newBoard[pos.y][pos.x] = _state.currentPiece!.color;
      }
    }

    _state = _state.copyWith(board: newBoard, clearCurrentPiece: true);
    
    final fullLines = _findFullLines();
    if (fullLines.isNotEmpty) {
      _clearLines(fullLines);
    } else {
      _spawnNextPiece();
    }
  }

  Set<int> _findFullLines() {
    final fullLines = <int>{};
    for (int y = 0; y < GameConstants.totalHeight; y++) {
      if (_state.board[y].every((cell) => cell != null)) {
        fullLines.add(y);
      }
    }
    return fullLines;
  }

  void _clearLines(Set<int> lines) {
    _state = _state.copyWith(clearingLines: lines);
    notifyListeners();

    // Animate line clear
    Future.delayed(Duration(milliseconds: 300), () {
      final newBoard = _state.board.map((row) => List<Color?>.from(row)).toList();
      final sortedLines = lines.toList()..sort((a, b) => b.compareTo(a));
      
      for (final line in sortedLines) {
        newBoard.removeAt(line);
        newBoard.insert(0, List.filled(GameConstants.boardWidth, null));
      }

      final linesCount = lines.length;
      final points = GameConstants.lineClearPoints[linesCount] ?? 0;
      final levelMultiplier = _state.level;
      final newLinesCleared = _state.linesCleared + linesCount;
      final newLevel = GameConstants.getLevel(newLinesCleared);

      _state = _state.copyWith(
        board: newBoard,
        score: _state.score + (points * levelMultiplier),
        linesCleared: newLinesCleared,
        level: newLevel,
        clearingLines: {},
      );

      if (newLevel > _state.level) {
        _startGravityTimer(); // Restart with new speed
      }

      _spawnNextPiece();
    });
  }

  void _startGravityTimer() {
    _gravityTimer?.cancel();
    final speed = GameConstants.getGravitySpeed(_state.level);
    _gravityTimer = Timer.periodic(Duration(milliseconds: speed), (_) {
      if (_state.status == GameStatus.playing) {
        if (!_movePiece(0, 1)) {
          _lockTimer ??= Timer(Duration(milliseconds: GameConstants.lockDelay), _lockPiece);
        }
      }
    });
  }

  void _resetLockTimer() {
    _lockTimer?.cancel();
    _lockTimer = null;
  }

  void _stopTimers() {
    _gravityTimer?.cancel();
    _lockTimer?.cancel();
    _dasTimer?.cancel();
    _arrTimer?.cancel();
  }

  void _gameOver() {
    _state = _state.copyWith(status: GameStatus.gameOver);
    _stopTimers();
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTimers();
    super.dispose();
  }
}