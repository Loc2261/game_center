import 'package:flutter/material.dart';
import 'position.dart';

enum TetrominoType { I, O, T, S, Z, J, L }

class Tetromino {
  final TetrominoType type;
  final List<Position> blocks;
  final int rotation; // 0, 1, 2, 3
  final Position position;
  final Color color;

  Tetromino({
    required this.type,
    required this.blocks,
    this.rotation = 0,
    this.position = const Position(3, 0),
    required this.color,
  });

  factory Tetromino.fromType(TetrominoType type) {
    final data = _tetrominoData[type]!;
    return Tetromino(
      type: type,
      blocks: data['blocks'] as List<Position>,
      color: data['color'] as Color,
    );
  }

  static final Map<TetrominoType, Map<String, dynamic>> _tetrominoData = {
    TetrominoType.I: {
      'blocks': [
        Position(0, 1),
        Position(1, 1),
        Position(2, 1),
        Position(3, 1),
      ],
      'color': Color(0xFF00F0F0), // Cyan
    },
    TetrominoType.O: {
      'blocks': [
        Position(1, 0),
        Position(2, 0),
        Position(1, 1),
        Position(2, 1),
      ],
      'color': Color(0xFFF0F000), // Yellow
    },
    TetrominoType.T: {
      'blocks': [
        Position(1, 0),
        Position(0, 1),
        Position(1, 1),
        Position(2, 1),
      ],
      'color': Color(0xFFA000F0), // Purple
    },
    TetrominoType.S: {
      'blocks': [
        Position(1, 0),
        Position(2, 0),
        Position(0, 1),
        Position(1, 1),
      ],
      'color': Color(0xFF00F000), // Green
    },
    TetrominoType.Z: {
      'blocks': [
        Position(0, 0),
        Position(1, 0),
        Position(1, 1),
        Position(2, 1),
      ],
      'color': Color(0xFFF00000), // Red
    },
    TetrominoType.J: {
      'blocks': [
        Position(0, 0),
        Position(0, 1),
        Position(1, 1),
        Position(2, 1),
      ],
      'color': Color(0xFF0000F0), // Blue
    },
    TetrominoType.L: {
      'blocks': [
        Position(2, 0),
        Position(0, 1),
        Position(1, 1),
        Position(2, 1),
      ],
      'color': Color(0xFFF0A000), // Orange
    },
  };

  List<Position> get absolutePositions =>
      blocks.map((block) => block + position).toList();

  Tetromino copyWith({
    TetrominoType? type,
    List<Position>? blocks,
    int? rotation,
    Position? position,
    Color? color,
  }) {
    return Tetromino(
      type: type ?? this.type,
      blocks: blocks ?? this.blocks,
      rotation: rotation ?? this.rotation,
      position: position ?? this.position,
      color: color ?? this.color,
    );
  }

  Tetromino moveDown() => copyWith(position: Position(position.x, position.y + 1));
  Tetromino moveLeft() => copyWith(position: Position(position.x - 1, position.y));
  Tetromino moveRight() => copyWith(position: Position(position.x + 1, position.y));
  Tetromino moveUp() => copyWith(position: Position(position.x, position.y - 1));

  Tetromino rotate(bool clockwise) {
    if (type == TetrominoType.O) return this; // O piece doesn't rotate

    final newRotation = clockwise 
        ? (rotation + 1) % 4 
        : (rotation - 1 + 4) % 4;

    final rotatedBlocks = blocks.map((block) {
      if (clockwise) {
        return Position(-block.y, block.x);
      } else {
        return Position(block.y, -block.x);
      }
    }).toList();

    return copyWith(blocks: rotatedBlocks, rotation: newRotation);
  }
}