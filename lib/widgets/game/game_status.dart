import 'package:flutter/material.dart';

class GameStatus extends StatelessWidget {
  final bool isGameOver;
  final String? winner;
  final String currentPlayer;
  final String message;
  final bool isLoading;

  const GameStatus({
    Key? key,
    required this.isGameOver,
    this.winner,
    required this.currentPlayer,
    required this.message,
    required this.isLoading,
  }) : super(key: key);

  Color _getStatusColor() {
    if (isLoading) return Colors.orange;
    if (isGameOver) {
      if (winner == 'X') return Colors.green;
      if (winner == 'O') return Colors.red;
      return Colors.blue;
    }
    return Colors.blue;
  }

  String _getStatusText() {
    if (isLoading) return 'AI is thinking...';
    if (isGameOver) {
      if (winner == 'X') return 'You Win! 🎉';
      if (winner == 'O') return 'AI Wins! 🤖';
      return 'Draw! 🤝';
    }
    return currentPlayer == 'X' ? 'Your Turn' : 'AI Turn';
  }

  IconData _getStatusIcon() {
    if (isLoading) return Icons.hourglass_top;
    if (isGameOver) {
      if (winner == 'X') return Icons.emoji_events;
      if (winner == 'O') return Icons.computer;
      return Icons.handshake;
    }
    return currentPlayer == 'X' ? Icons.person : Icons.computer;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final statusText = _getStatusText();
    final statusIcon = _getStatusIcon();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
              if (message.isNotEmpty)
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
          const Spacer(),
          if (isLoading)
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
        ],
      ),
    );
  }
}