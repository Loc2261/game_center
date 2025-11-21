import 'package:flutter/material.dart';
import '../models/tetromino.dart';

class NextQueueWidget extends StatelessWidget {
  final List<TetrominoType> queue;

  const NextQueueWidget({Key? key, required this.queue}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'NEXT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          ...queue.take(3).map((type) => Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: TetrominoPreview(type: type, size: 60),
              )),
        ],
      ),
    );
  }
}

class TetrominoPreview extends StatelessWidget {
  final TetrominoType type;
  final double size;

  const TetrominoPreview({
    Key? key,
    required this.type,
    this.size = 80,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final piece = Tetromino.fromType(type);
    
    return Container(
      width: size,
      height: size,
      child: CustomPaint(
        painter: TetrominoPainter(piece),
      ),
    );
  }
}

class TetrominoPainter extends CustomPainter {
  final Tetromino piece;

  TetrominoPainter(this.piece);

  @override
  void paint(Canvas canvas, Size size) {
    final blockSize = size.width / 4;

    for (final block in piece.blocks) {
      final rect = Rect.fromLTWH(
        block.x * blockSize + 1,
        block.y * blockSize + 1,
        blockSize - 2,
        blockSize - 2,
      );

      final paint = Paint()
        ..color = piece.color
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(2)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(TetrominoPainter oldDelegate) => false;
}