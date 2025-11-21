class CubicState {
  final String id;
  final List<List<String>> frontFace;
  final List<List<String>> backFace;
  final List<List<String>> leftFace;
  final List<List<String>> rightFace;
  final List<List<String>> topFace;
  final List<List<String>> bottomFace;

  CubicState({
    required this.id,
    required this.frontFace,
    required this.backFace,
    required this.leftFace,
    required this.rightFace,
    required this.topFace,
    required this.bottomFace,
  });

  factory CubicState.fromJson(Map<String, dynamic> json) {
    return CubicState(
      id: json['id'] ?? '',
      frontFace: _parseFace(json['frontFace']),
      backFace: _parseFace(json['backFace']),
      leftFace: _parseFace(json['leftFace']),
      rightFace: _parseFace(json['rightFace']),
      topFace: _parseFace(json['topFace']),
      bottomFace: _parseFace(json['bottomFace']),
    );
  }

  static List<List<String>> _parseFace(dynamic face) {
    if (face == null) return List.generate(3, (_) => List.filled(3, 'W'));
    return (face as List).map((row) => List<String>.from(row)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'frontFace': frontFace,
      'backFace': backFace,
      'leftFace': leftFace,
      'rightFace': rightFace,
      'topFace': topFace,
      'bottomFace': bottomFace,
    };
  }

  bool get isSolved {
    return _isFaceSolved(frontFace) &&
        _isFaceSolved(backFace) &&
        _isFaceSolved(leftFace) &&
        _isFaceSolved(rightFace) &&
        _isFaceSolved(topFace) &&
        _isFaceSolved(bottomFace);
  }

  bool _isFaceSolved(List<List<String>> face) {
    final centerColor = face[1][1];
    for (var row in face) {
      for (var color in row) {
        if (color != centerColor) return false;
      }
    }
    return true;
  }
}

class CubicMove {
  final String move;
  final bool isPrime;
  final bool isDouble;
  final String description;
  final int stepNumber;

  CubicMove({
    required this.move,
    this.isPrime = false,
    this.isDouble = false,
    required this.description,
    required this.stepNumber,
  });

  factory CubicMove.fromJson(Map<String, dynamic> json) {
    return CubicMove(
      move: json['move'] ?? '',
      isPrime: json['isPrime'] ?? false,
      isDouble: json['isDouble'] ?? false,
      description: json['description'] ?? '',
      stepNumber: json['stepNumber'] ?? 0,
    );
  }

  String get notation {
    String notation = move;
    if (isPrime) notation += "'";
    if (isDouble) notation += "2";
    return notation;
  }
}

class CubicSolution {
  final String solutionType;
  final List<CubicMove> moves;
  final int moveCount;
  final int estimatedSeconds;
  final String notation;
  final bool success;
  final String message;

  CubicSolution({
    required this.solutionType,
    required this.moves,
    required this.moveCount,
    required this.estimatedSeconds,
    required this.notation,
    required this.success,
    required this.message,
  });

  factory CubicSolution.fromJson(Map<String, dynamic> json) {
    return CubicSolution(
      solutionType: json['solutionType'] ?? '',
      moves: (json['moves'] as List? ?? []).map((m) => CubicMove.fromJson(m)).toList(),
      moveCount: json['moveCount'] ?? 0,
      estimatedSeconds: json['estimatedSeconds'] ?? 0,
      notation: json['notation'] ?? '',
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}
