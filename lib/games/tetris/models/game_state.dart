import 'package:flutter/material.dart';
import 'tetromino.dart';

enum GameStatus { menu, playing, paused, gameOver }

class GameState {
  final List<List<Color?>> board;
  final Tetromino? currentPiece;
  final Tetromino? holdPiece;
  final List<TetrominoType> nextQueue;
  final int score;
  final int level;
  final int linesCleared;
  final GameStatus status;
  final bool canHold;
  final Set<int> clearingLines;
  final int ghostPieceY;

  GameState({
    required this.board,
    this.currentPiece,
    this.holdPiece,
    required this.nextQueue,
    this.score = 0,
    this.level = 1,
    this.linesCleared = 0,
    this.status = GameStatus.menu,
    this.canHold = true,
    this.clearingLines = const {},
    this.ghostPieceY = 0,
  });

  factory GameState.initial() {
    return GameState(
      board: List.generate(
        24,
        (_) => List.filled(10, null),
      ),
      nextQueue: [],
      status: GameStatus.menu,
    );
  }

  GameState copyWith({
    List<List<Color?>>? board,
    Tetromino? currentPiece,
    Tetromino? holdPiece,
    List<TetrominoType>? nextQueue,
    int? score,
    int? level,
    int? linesCleared,
    GameStatus? status,
    bool? canHold,
    Set<int>? clearingLines,
    int? ghostPieceY,
    bool clearCurrentPiece = false,
    bool clearHoldPiece = false,
  }) {
    return GameState(
      board: board ?? this.board.map((row) => List<Color?>.from(row)).toList(),
      currentPiece: clearCurrentPiece ? null : (currentPiece ?? this.currentPiece),
      holdPiece: clearHoldPiece ? null : (holdPiece ?? this.holdPiece),
      nextQueue: nextQueue ?? this.nextQueue,
      score: score ?? this.score,
      level: level ?? this.level,
      linesCleared: linesCleared ?? this.linesCleared,
      status: status ?? this.status,
      canHold: canHold ?? this.canHold,
      clearingLines: clearingLines ?? this.clearingLines,
      ghostPieceY: ghostPieceY ?? this.ghostPieceY,
    );
  }
}