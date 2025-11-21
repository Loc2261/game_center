import 'package:flutter/material.dart';
import '../models/tetromino.dart';
import 'next_queue_widget.dart';

class HoldPieceWidget extends StatelessWidget {
  final Tetromino? holdPiece;
  final bool canHold;

  const HoldPieceWidget({
    Key? key,
    this.holdPiece,
    required this.canHold,
  }) : super(key: key);

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
            'HOLD',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Container(
            width: 80,
            height: 80,
            child: holdPiece != null
                ? Opacity(
                    opacity: canHold ? 1.0 : 0.5,
                    child: TetrominoPreview(type: holdPiece!.type),
                  )
                : Center(
                    child: Text(
                      'Empty',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}