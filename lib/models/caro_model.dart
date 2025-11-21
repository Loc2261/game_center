class CaroGame {
  final String gameId;
  final List<String> board;
  final String difficulty;
  final bool isGameOver;
  final String? winner;
  final String currentPlayer;
  final String message;
  final List<CaroMove> moveHistory;
  final bool success;

  CaroGame({
    required this.gameId,
    required this.board,
    required this.difficulty,
    required this.isGameOver,
    this.winner,
    required this.currentPlayer,
    required this.message,
    required this.moveHistory,
    required this.success,
  });

  factory CaroGame.fromJson(Map<String, dynamic> json) {
    return CaroGame(
      gameId: json['gameId'] ?? '',
      board: List<String>.from(json['board'] ?? []),
      difficulty: json['difficulty'] ?? 'easy',
      isGameOver: json['isGameOver'] ?? false,
      winner: json['winner'],
      currentPlayer: json['currentPlayer'] ?? 'X',
      message: json['message'] ?? '',
      moveHistory: (json['moveHistory'] as List? ?? [])
          .map((move) => CaroMove.fromJson(move))
          .toList(),
      success: json['success'] ?? false,
    );
  }
}

class CaroMove {
  final String gameId;
  final int row;
  final int col;

  CaroMove({
    required this.gameId,
    required this.row,
    required this.col,
  });

  Map<String, dynamic> toJson() {
    return {
      'gameId': gameId,
      'row': row,
      'col': col,
    };
  }

  factory CaroMove.fromJson(Map<String, dynamic> json) {
    return CaroMove(
      gameId: json['gameId'] ?? '',
      row: json['row'] ?? 0,
      col: json['col'] ?? 0,
    );
  }
}

class CaroGameResult {
  final String difficulty;
  final bool isWin;
  final int totalMoves;
  final int playerMoves;
  final int computerMoves;
  final int mistakes;
  final Duration completionTime;
  final String? gameId;

  CaroGameResult({
    required this.difficulty,
    required this.isWin,
    required this.totalMoves,
    required this.playerMoves,
    required this.computerMoves,
    required this.mistakes,
    required this.completionTime,
    this.gameId,
  });

  Map<String, dynamic> toJson() {
    return {
      'difficulty': difficulty,
      'isWin': isWin,
      'totalMoves': totalMoves,
      'playerMoves': playerMoves,
      'computerMoves': computerMoves,
      'mistakes': mistakes,
      'completionTime': completionTime.inSeconds,
      'gameId': gameId,
    };
  }
}