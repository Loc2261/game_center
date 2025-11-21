import 'package:flutter/material.dart';
import '../../models/caro_model.dart'; 
class CaroBoard extends StatefulWidget {
  final List<String> board;
  final Function(int, int) onCellTap;
  final bool isEnabled;
  final CaroMove? lastMove;

  const CaroBoard({
    super.key,
    required this.board,
    required this.onCellTap,
    this.isEnabled = true,
    this.lastMove, 
  });

  @override
  _CaroBoardState createState() => _CaroBoardState();
}

class _CaroBoardState extends State<CaroBoard> with TickerProviderStateMixin {
  final TransformationController _transformationController = TransformationController();
  late AnimationController _animationController;
  Animation<Matrix4>? _animationReset;
  double _currentScale = 1.0;
  final double _minScale = 0.5;
  final double _maxScale = 3.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _animationReset = Matrix4Tween(
      begin: _transformationController.value,
      end: Matrix4.identity(),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.addListener(() {
      if (_animationReset != null) {
        _transformationController.value = _animationReset!.value;
      }
    });

    _animationController.forward(from: 0).whenComplete(() {
      _animationReset?.removeListener(() {});
      setState(() {
        _currentScale = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InteractiveViewer(
          transformationController: _transformationController,
          minScale: _minScale,
          maxScale: _maxScale,
          constrained: false,
          boundaryMargin: const EdgeInsets.all(100.0),
          onInteractionUpdate: (details) {
            setState(() {
               _currentScale = _transformationController.value.getMaxScaleOnAxis();
            });
          },
          child: Center(
            child: _buildBoardWithIndicators(),
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: _buildZoomControls(),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: _buildZoomIndicator(),
        ),
      ],
    );
  }

  Widget _buildBoardWithIndicators() {
    final boardSize = widget.board.isNotEmpty ? widget.board.length : 15;
    const double cellSize = 30.0; 
    const double indicatorSize = 20.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: indicatorSize),
              ...List.generate(
                boardSize,
                (index) => SizedBox(
                  width: cellSize,
                  height: indicatorSize,
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(fontSize: 10, color: Colors.blue[400]),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  boardSize,
                  (index) => SizedBox(
                    width: indicatorSize,
                    height: cellSize,
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(fontSize: 10, color: Colors.blue[400]),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: cellSize * boardSize,
                height: cellSize * boardSize,
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0A0A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[800]!, width: 1.5),
                ),
                child: GridView.builder(
                  itemCount: boardSize * boardSize,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: boardSize,
                  ),
                  itemBuilder: (context, index) {
                    final i = index ~/ boardSize; // row
                    final j = index % boardSize;  // column
                    return _CaroCell(
                      row: i, // <-- pass row
                      col: j, // <-- pass col
                      value: (i < widget.board.length && j < widget.board[i].length) ? widget.board[i][j] : ' ',
                      onTap: () => widget.onCellTap(i, j),
                      isEnabled: widget.isEnabled,
                      lastMove: widget.lastMove, // <-- pass last move
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildZoomControls() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A).withOpacity(0.9),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.blue[800]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.zoom_in, color: Colors.white),
            onPressed: () {
              final newScale = (_currentScale * 1.2).clamp(_minScale, _maxScale);
              _transformationController.value = Matrix4.identity()..scale(newScale);
              setState(() {
                _currentScale = newScale;
              });
            },
          ),
          Container(height: 1, width: 30, color: Colors.blue[800]),
          IconButton(
            icon: const Icon(Icons.zoom_out, color: Colors.white),
            onPressed: () {
              final newScale = (_currentScale * 0.8).clamp(_minScale, _maxScale);
              _transformationController.value = Matrix4.identity()..scale(newScale);
              setState(() {
                _currentScale = newScale;
              });
            },
          ),
          Container(height: 1, width: 30, color: Colors.blue[800]),
          IconButton(
            icon: const Icon(Icons.center_focus_strong, color: Colors.white),
            onPressed: _resetZoom,
          ),
        ],
      ),
    );
  }

  Widget _buildZoomIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A).withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue[800]!),
      ),
      child: Text(
        '${(_currentScale * 100).toStringAsFixed(0)}%',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _CaroCell extends StatefulWidget {
  final int row;
  final int col;
  final String value;
  final VoidCallback onTap;
  final bool isEnabled;
  final CaroMove? lastMove;

  const _CaroCell({
    required this.row,
    required this.col,
    required this.value,
    required this.onTap,
    required this.isEnabled,
    this.lastMove,
  });

  @override
  State<_CaroCell> createState() => _CaroCellState();
}

class _CaroCellState extends State<_CaroCell> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getCellColor() {
    if (widget.value == 'X') return const Color(0xFF00E5FF);
    if (widget.value == 'O') return const Color(0xFFFF4081);
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = widget.value == ' ';
    final cellColor = _getCellColor();
    
    // --- CHANGE: Check if this cell is the opponent's last move ---
    final bool isOpponentLastMove = widget.lastMove != null &&
        widget.lastMove!.row == widget.row &&
        widget.lastMove!.col == widget.col &&
        widget.value == 'O';

    return GestureDetector(
      onTapDown: (_) {
        if (widget.isEnabled && isEmpty) _controller.forward();
      },
      onTapUp: (_) {
        if (widget.isEnabled && isEmpty) _controller.reverse();
      },
      onTapCancel: () {
        if (widget.isEnabled && isEmpty) _controller.reverse();
      },
      onTap: widget.isEnabled && isEmpty ? widget.onTap : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.all(1.0),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(4),
            // --- CHANGE: Add a conditional box shadow for the highlight ---
            boxShadow: isOpponentLastMove
                ? [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.6),
                      blurRadius: 6.0,
                      spreadRadius: 1.0,
                    )
                  ]
                : null,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: widget.value == ' '
                ? const SizedBox.shrink()
                : Center(
                    key: ValueKey(widget.value),
                    child: LayoutBuilder(builder: (context, constraints) {
                      return Text(
                        widget.value,
                        style: TextStyle(
                          fontSize: constraints.maxWidth * 0.65,
                          fontWeight: FontWeight.bold,
                          color: cellColor,
                          shadows: [
                            Shadow(color: cellColor.withOpacity(0.8), blurRadius: 8),
                          ],
                        ),
                      );
                    }),
                  ),
          ),
        ),
      ),
    );
  }
}