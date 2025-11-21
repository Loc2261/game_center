import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import 'game_screen.dart';

// This screen acts as a wrapper to provide the GameController to the Tetris game UI.
class TetrisLauncherScreen extends StatelessWidget {
  const TetrisLauncherScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        // Create the game controller and immediately start the game
        final controller = GameController();
        controller.startGame();
        return controller;
      },
      child: const GameScreen(), // The main UI for the Tetris game
    );
  }
}