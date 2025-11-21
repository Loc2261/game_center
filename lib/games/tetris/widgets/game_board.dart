import 'package:flutter/material.dart';
import '../models/game_state.dart';

import '../config/constants.dart';

class GameBoard extends StatelessWidget {
  final GameState state;

  const GameBoard({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: GameConstants.boardWidth / GameConstants.boardHeight,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.grey[700]!, width: 2),
        ),
        child: CustomPaint(
          painter: BoardPainter(state),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class BoardPainter extends CustomPainter {
  final GameState state;

  BoardPainter(this.state);

  @override
  void paint(Canvas canvas, Size size) {
    final blockWidth = size.width / GameConstants.boardWidth;
    final blockHeight = size.height / GameConstants.boardHeight;

    // Draw grid
    _drawGrid(canvas, size, blockWidth, blockHeight);

    // Draw locked blocks
    _drawLockedBlocks(canvas, blockWidth, blockHeight);

    // Draw ghost piece
    _drawGhostPiece(canvas, blockWidth, blockHeight);

    // Draw current piece
    _drawCurrentPiece(canvas, blockWidth, blockHeight);

    // Draw clearing lines animation
    _drawClearingLines(canvas, size, blockWidth, blockHeight);
  }

  void _drawGrid(Canvas canvas, Size size, double blockWidth, double blockHeight) {
    final paint = Paint()
      ..color = Colors.grey[900]!
      ..strokeWidth = 0.5;

    for (int x = 0; x <= GameConstants.boardWidth; x++) {
      canvas.drawLine(
        Offset(x * blockWidth, 0),
        Offset(x * blockWidth, size.height),
        paint,
      );
    }

    for (int y = 0; y <= GameConstants.boardHeight; y++) {
      canvas.drawLine(
        Offset(0, y * blockHeight),
        Offset(size.width, y * blockHeight),
        paint,
      );
    }
  }

  void _drawLockedBlocks(Canvas canvas, double blockWidth, double blockHeight) {
    for (int y = GameConstants.bufferZone; y < GameConstants.totalHeight; y++) {
      for (int x = 0; x < GameConstants.boardWidth; x++) {
        final color = state.board[y][x];
        if (color != null) {
          _drawBlock(
            canvas,
            x,
            y - GameConstants.bufferZone,
            color,
            blockWidth,
            blockHeight,
          );
        }
      }
    }
  }

  void _drawGhostPiece(Canvas canvas, double blockWidth, double blockHeight) {
    if (state.currentPiece == null) return;

    final ghostY = state.ghostPieceY;
    final piece = state.currentPiece!;
    final ghostColor = piece.color.withOpacity(0.3);

    for (final block in piece.blocks) {
      final x = block.x + piece.position.x;
      final y = block.y + ghostY;

      if (y >= GameConstants.bufferZone) {
        _drawBlock(
          canvas,
          x,
          y - GameConstants.bufferZone,
          ghostColor,
          blockWidth,
          blockHeight,
          isGhost: true,
        );
      }
    }
  }

  void _drawCurrentPiece(Canvas canvas, double blockWidth, double blockHeight) {
    if (state.currentPiece == null) return;

    for (final pos in state.currentPiece!.absolutePositions) {
      if (pos.y >= GameConstants.bufferZone) {
        _drawBlock(
          canvas,
          pos.x,
          pos.y - GameConstants.bufferZone,
          state.currentPiece!.color,
          blockWidth,
          blockHeight,
        );
      }
    }
  }

  void _drawBlock(
    Canvas canvas,
    int x,
    int y,
    Color color,
    double blockWidth,
    double blockHeight, {
    bool isGhost = false,
  }) {
    final rect = Rect.fromLTWH(
      x * blockWidth + 1,
      y * blockHeight + 1,
      blockWidth - 2,
      blockHeight - 2,
    );

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(2)),
      paint,
    );

    if (!isGhost) {
      // Draw highlight
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(rect.left, rect.top, rect.width, rect.height * 0.3),
          Radius.circular(2),
        ),
        highlightPaint,
      );

      // Draw border
      final borderPaint = Paint()
        ..color = color.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(2)),
        borderPaint,
      );
    }
  }

  void _drawClearingLines(
    Canvas canvas,
    Size size,
    double blockWidth,
    double blockHeight,
  ) {
    if (state.clearingLines.isEmpty) return;

    final paint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    for (final line in state.clearingLines) {
      if (line >= GameConstants.bufferZone) {
        final y = (line - GameConstants.bufferZone) * blockHeight;
        canvas.drawRect(
          Rect.fromLTWH(0, y, size.width, blockHeight),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(BoardPainter oldDelegate) => true;
}