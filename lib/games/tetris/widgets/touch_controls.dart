import 'package:flutter/material.dart';

class TouchControls extends StatelessWidget {
  final VoidCallback onMoveLeft;
  final VoidCallback onMoveRight;
  final VoidCallback onRotateCW;
  final VoidCallback onRotateCCW;
  final VoidCallback onSoftDrop;
  final VoidCallback onHardDrop;
  final VoidCallback onHold;
  final VoidCallback onStopMove;

  const TouchControls({
    Key? key,
    required this.onMoveLeft,
    required this.onMoveRight,
    required this.onRotateCW,
    required this.onRotateCCW,
    required this.onSoftDrop,
    required this.onHardDrop,
    required this.onHold,
    required this.onStopMove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left controls
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildControlButton(
                icon: Icons.swap_horiz,
                onPressed: onHold,
                label: 'HOLD',
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  GestureDetector(
                    onTapDown: (_) => onMoveLeft(),
                    onTapUp: (_) => onStopMove(),
                    onTapCancel: onStopMove,
                    child: _buildControlButton(
                      icon: Icons.arrow_left,
                      onPressed: () {},
                    ),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTapDown: (_) => onSoftDrop(),
                    child: _buildControlButton(
                      icon: Icons.arrow_downward,
                      onPressed: () {},
                    ),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTapDown: (_) => onMoveRight(),
                    onTapUp: (_) => onStopMove(),
                    onTapCancel: onStopMove,
                    child: _buildControlButton(
                      icon: Icons.arrow_right,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Right controls
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildControlButton(
                icon: Icons.vertical_align_bottom,
                onPressed: onHardDrop,
                label: 'DROP',
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  _buildControlButton(
                    icon: Icons.rotate_left,
                    onPressed: onRotateCCW,
                  ),
                  SizedBox(width: 8),
                  _buildControlButton(
                    icon: Icons.rotate_right,
                    onPressed: onRotateCW,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    String? label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[600]!),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(8),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
          ),
        ),
        if (label != null) ...[
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.grey[400], fontSize: 10),
          ),
        ],
      ],
    );
  }
}