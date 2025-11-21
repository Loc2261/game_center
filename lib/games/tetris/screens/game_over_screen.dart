import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/game_model.dart';
import '../../../providers/game_provider.dart'; 
import '../controllers/game_controller.dart';   
import '../models/tetris_game_dto.dart';     
  

class GameOverScreen extends StatefulWidget {
  const GameOverScreen({Key? key}) : super(key: key);

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> {
  bool _isSaving = false;
  bool _hasSaved = false;

  Future<void> _saveScore(BuildContext context) async {
    if (_isSaving || _hasSaved) return;

    setState(() => _isSaving = true);

    final gameController = context.read<GameController>();
    final gameProvider = context.read<GameProvider>();

    final tetrisResult = TetrisResultDto(
      finalScore: gameController.state.score,
      finalLevel: gameController.state.level,
      linesCleared: gameController.state.linesCleared,
      durationSeconds: 300, // Placeholder: you would track this properly
    );

    final request = GameCompleteRequest(
      gameType: 'Tetris',
      tetrisResult: tetrisResult,
    );

    try {
      await gameProvider.submitGameCompletion(request);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Score saved successfully!'), backgroundColor: Colors.green),
        );
        setState(() => _hasSaved = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save score: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    
    return Container(
      color: Colors.black87,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.block,
                size: 80,
                color: Colors.red,
              ),
              SizedBox(height: 24),
              Text(
                'GAME OVER',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 24),
              _buildStat('FINAL SCORE', controller.state.score.toString()),
              SizedBox(height: 12),
              _buildStat('LEVEL', controller.state.level.toString()),
              SizedBox(height: 12),
              _buildStat('LINES CLEARED', controller.state.linesCleared.toString()),
              SizedBox(height: 32),
              _buildButton(
                context,
                _hasSaved ? 'SAVED' : 'SAVE SCORE',
                _isSaving ? null : Icons.save,
                _isSaving || _hasSaved ? () {} : () => _saveScore(context),
                color: Colors.green,
                child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : null,
              ),
              const SizedBox(height: 12),
              _buildButton(
                context,
                'PLAY AGAIN',
                Icons.refresh,
                () => controller.restartGame(),
              ),
              SizedBox(height: 12),
              _buildButton(
                context,
                'MAIN MENU',
                Icons.home,
                () => controller.quitGame(context),  // FIXED
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildButton(
    BuildContext context,
    String text,
    IconData? icon,
    VoidCallback onPressed, {
    Color color = Colors.red,
    Widget? child,
  }) {
    return SizedBox(
      width: 200,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        child: child ?? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if(icon != null) Icon(icon),
            if(icon != null) const SizedBox(width: 8),
            Text(text),
          ],
        ),
      ),
    );
  }
}