import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../controllers/game_controller.dart';
import '../widgets/game_board.dart';
import '../widgets/next_queue_widget.dart';
import '../widgets/hold_piece_widget.dart';
import '../widgets/hud.dart';
import '../widgets/touch_controls.dart';
import 'pause_screen.dart';
import 'game_over_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event, GameController controller) {
    if (event is! KeyDownEvent) return;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        controller.startAutoMove(-1);
        break;
      case LogicalKeyboardKey.arrowRight:
        controller.startAutoMove(1);
        break;
      case LogicalKeyboardKey.arrowDown:
        controller.softDrop();
        break;
      case LogicalKeyboardKey.space:
        controller.hardDrop();
        break;
      case LogicalKeyboardKey.keyZ:
        controller.rotateCCW();
        break;
      case LogicalKeyboardKey.keyX:
      case LogicalKeyboardKey.arrowUp:
        controller.rotateCW();
        break;
      case LogicalKeyboardKey.keyC:
        controller.holdPiece();
        break;
      case LogicalKeyboardKey.keyP:
      case LogicalKeyboardKey.escape:
        controller.pauseGame();
        break;
    }
  }

  void _handleKeyUpEvent(KeyEvent event, GameController controller) {
    if (event is! KeyUpEvent) return;

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
        event.logicalKey == LogicalKeyboardKey.arrowRight) {
      controller.stopAutoMove();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (context, controller, _) {
        return KeyboardListener(
          focusNode: _focusNode,
          onKeyEvent: (event) {
            _handleKeyEvent(event, controller);
            _handleKeyUpEvent(event, controller);
          },
          child: Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isPortrait = constraints.maxHeight > constraints.maxWidth;
                      
                      return isPortrait
                          ? _buildPortraitLayout(controller)
                          : _buildLandscapeLayout(controller);
                    },
                  ),
                ),
                if (controller.state.status == GameStatus.paused)
                  PauseScreen(),
                if (controller.state.status == GameStatus.gameOver)
                  GameOverScreen(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPortraitLayout(GameController controller) {
    return Column(
      children: [
        // Top bar
        Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              HoldPieceWidget(
                holdPiece: controller.state.holdPiece,
                canHold: controller.state.canHold,
              ),
              HUD(state: controller.state),
              NextQueueWidget(queue: controller.state.nextQueue),
            ],
          ),
        ),
        // Game board
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: GameBoard(state: controller.state),
          ),
        ),
        // Touch controls
        TouchControls(
          onMoveLeft: () => controller.startAutoMove(-1),
          onMoveRight: () => controller.startAutoMove(1),
          onRotateCW: controller.rotateCW,
          onRotateCCW: controller.rotateCCW,
          onSoftDrop: controller.softDrop,
          onHardDrop: controller.hardDrop,
          onHold: controller.holdPiece,
          onStopMove: controller.stopAutoMove,
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(GameController controller) {
    return Row(
      children: [
        // Left side
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HoldPieceWidget(
                holdPiece: controller.state.holdPiece,
                canHold: controller.state.canHold,
              ),
              SizedBox(height: 16),
              HUD(state: controller.state),
            ],
          ),
        ),
        // Center - Game board
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: GameBoard(state: controller.state),
        ),
        // Right side
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NextQueueWidget(queue: controller.state.nextQueue),
              SizedBox(height: 32),
              // Simplified controls for landscape
              Column(
                children: [
                  ElevatedButton(
                    onPressed: controller.rotateCW,
                    child: Text('ROTATE'),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: controller.hardDrop,
                    child: Text('DROP'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}