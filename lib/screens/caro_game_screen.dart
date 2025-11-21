import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../widgets/game/caro_board.dart';
import '../widgets/game/difficulty_selector.dart';
import '../widgets/game/game_status.dart';

class CaroGameScreen extends StatefulWidget {
  const CaroGameScreen({super.key});

  @override
  State<CaroGameScreen> createState() => _CaroGameScreenState();
}

class _CaroGameScreenState extends State<CaroGameScreen> {
  String _selectedDifficulty = 'easy';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startNewGame();
    });
  }

  void _startNewGame() {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    gameProvider.startNewCaroGame(_selectedDifficulty);
  }

  void _onCellTap(int row, int col) {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    if (gameProvider.currentCaroGame != null &&
        !gameProvider.currentCaroGame!.isGameOver &&
        !gameProvider.isLoading) {
      gameProvider.makeCaroMove(row, col).then((_) {
        if (mounted && (gameProvider.currentCaroGame?.isGameOver ?? false)) {
          _showResultDialog();
        }
      });
    }
  }

  void _showResultDialog() {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final game = gameProvider.currentCaroGame;
    if (game == null) return;

    final title = game.winner == 'X'
        ? '🎉 You Won! 🎉'
        : game.winner == 'O'
            ? '🤖 AI Won 🤖'
            : '🤝 It\'s a Draw! 🤝';
    final color = game.winner == 'X'
        ? Colors.greenAccent
        : game.winner == 'O'
            ? Colors.redAccent
            : Colors.amber;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(
          child: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ),
        content: const Text(
          'Your score has been submitted. Play again to climb the leaderboard!',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('View Board'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startNewGame();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<GameProvider>(
          builder: (context, gameProvider, child) {
            final game = gameProvider.currentCaroGame;
            // --- CHANGE: Get the last move from the game history ---
            final lastMove = (game != null && game.moveHistory.isNotEmpty)
                ? game.moveHistory.last
                : null;

            return Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: theme.cardColor,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const Text('Tic Tac Toe', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: _startNewGame,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      DifficultySelector(
                        selectedDifficulty: _selectedDifficulty,
                        onDifficultyChanged: (difficulty) {
                          setState(() => _selectedDifficulty = difficulty);
                          _startNewGame();
                        },
                      ),
                    ],
                  ),
                ),
                if (game != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GameStatus(
                      isGameOver: game.isGameOver,
                      winner: game.winner,
                      currentPlayer: game.currentPlayer,
                      message: game.message,
                      isLoading: gameProvider.isLoading,
                    ),
                  ),

                Expanded(
                  child: game == null
                      ? const Center(child: CircularProgressIndicator())
                      : CaroBoard(
                          board: game.board,
                          onCellTap: _onCellTap,
                          isEnabled: !game.isGameOver && game.currentPlayer == 'X' && !gameProvider.isLoading,
                          // --- CHANGE: Pass the last move to the board ---
                          lastMove: lastMove,
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}