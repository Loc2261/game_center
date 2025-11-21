import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:cuber/cuber.dart';
import '../models/cubic_model.dart';

class CubicSolverProvider with ChangeNotifier {
  CubicState? _cubeState;
  CubicSolution? _solution;
  bool _isLoading = false;
  String _error = '';
  String? _currentMove;
  bool _isAnimating = false;
  int _currentStepIndex = 0; // number of moves already applied
  final Map<String, bool> _capturedFaces = {};

  CubicState get cubeState => _cubeState ?? _getDefaultCube();
  CubicSolution? get solution => _solution;
  bool get isLoading => _isLoading;
  String get error => _error;
  String? get currentMove => _currentMove;
  bool get isAnimating => _isAnimating;
  int get currentStepIndex => _currentStepIndex;
  int get totalSteps => _solution?.moves.length ?? 0;

  CubicSolverProvider() {
    initializeCube();
  }

  void initializeCube() {
    _cubeState = _getDefaultCube();
    _solution = null;
    _currentMove = null;
    _currentStepIndex = 0;
    _capturedFaces.clear();
    _error = '';
    notifyListeners();
  }

  CubicState _getDefaultCube() {
    return CubicState(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      frontFace: List.generate(3, (_) => List.filled(3, 'G')),
      backFace: List.generate(3, (_) => List.filled(3, 'B')),
      leftFace: List.generate(3, (_) => List.filled(3, 'O')),
      rightFace: List.generate(3, (_) => List.filled(3, 'R')),
      topFace: List.generate(3, (_) => List.filled(3, 'W')),
      bottomFace: List.generate(3, (_) => List.filled(3, 'Y')),
    );
  }

  // Placeholder image processing; keep/replace with your detection code
  Future<void> processImage(String imagePath, String faceName) async {
    _capturedFaces[faceName] = true;
    notifyListeners();
  }

  void updateFaceColor(String face, int row, int col, String color) {
    switch (face.toLowerCase()) {
      case 'front':
        _cubeState!.frontFace[row][col] = color;
        break;
      case 'back':
        _cubeState!.backFace[row][col] = color;
        break;
      case 'left':
        _cubeState!.leftFace[row][col] = color;
        break;
      case 'right':
        _cubeState!.rightFace[row][col] = color;
        break;
      case 'top':
        _cubeState!.topFace[row][col] = color;
        break;
      case 'bottom':
        _cubeState!.bottomFace[row][col] = color;
        break;
    }
    notifyListeners();
  }

  bool validateCubeState() {
    if (_cubeState == null) return false;

    Map<String, int> colorCount = {
      'W': 0, 'Y': 0, 'R': 0, 'O': 0, 'G': 0, 'B': 0,
    };

    _countFaceColors(_cubeState!.frontFace, colorCount);
    _countFaceColors(_cubeState!.backFace, colorCount);
    _countFaceColors(_cubeState!.leftFace, colorCount);
    _countFaceColors(_cubeState!.rightFace, colorCount);
    _countFaceColors(_cubeState!.topFace, colorCount);
    _countFaceColors(_cubeState!.bottomFace, colorCount);

    for (var count in colorCount.values) {
      if (count != 9) return false;
    }

    return true;
  }

  void _countFaceColors(List<List<String>> face, Map<String, int> colorCount) {
    for (var row in face) {
      for (var color in row) {
        if (colorCount.containsKey(color)) {
          colorCount[color] = colorCount[color]! + 1;
        }
      }
    }
  }

  // --- Client-side solver (optimal using cuber) ---
  Future<void> solveCube(String solutionType) async {
    _setLoading(true);
    _error = '';
    notifyListeners();

    try {
      if (!validateCubeState()) {
        _error = 'Invalid cube state. Each color must appear exactly 9 times.';
        _setLoading(false);
        notifyListeners();
        return;
      }

      final facelet = _toFaceletString(_cubeState!); // U R F D L B order
      final cube = Cube.from(facelet);

      // Use cuber solver (defaults to kociemba)
      final solution = cube.solve(); // may return Solution or null
      if (solution == null) {
        _solution = CubicSolution(
          solutionType: 'optimal',
          moves: [],
          moveCount: 0,
          estimatedSeconds: 0,
          notation: '',
          success: false,
          message: 'No solution found within timeout.',
        );
        _currentStepIndex = 0;
        _setLoading(false);
        notifyListeners();
        return;
      }

      // solution.toString() usually gives algorithm notation
      final movesString = solution.toString().trim();
      if (movesString.isEmpty) {
        _solution = CubicSolution(
          solutionType: 'optimal',
          moves: [],
          moveCount: 0,
          estimatedSeconds: 0,
          notation: '',
          success: true,
          message: 'Cube already solved.',
        );
        _currentStepIndex = 0;
        _setLoading(false);
        notifyListeners();
        return;
      }

      final rawMoves = _parseMoveString(movesString);
      final List<CubicMove> moves = [];
      for (int i = 0; i < rawMoves.length; i++) {
        final m = rawMoves[i];
        final base = m[0];
        final isDouble = m.contains('2');
        final isPrime = m.contains("'");
        moves.add(CubicMove(
          move: base,
          isPrime: isPrime,
          isDouble: isDouble,
          description: '',
          stepNumber: i,
        ));
      }

      final notation = moves.map((m) => m.notation).join(' ');

      _solution = CubicSolution(
        solutionType: 'optimal',
        moves: moves,
        moveCount: moves.length,
        estimatedSeconds: max(1, moves.length),
        notation: notation,
        success: true,
        message: 'Solved locally (optimal).',
      );

      _currentStepIndex = 0;
      notifyListeners();
    } catch (e) {
      _error = 'Error solving cube locally: ${e.toString()}';
      _solution = null;
      notifyListeners();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  List<String> _parseMoveString(String s) {
    final tokens = s.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    return tokens;
  }

  // --- Apply a single move (or a small algorithm) locally ---
  Future<void> applyMove(String moveNotation) async {
    _currentMove = moveNotation;
    notifyListeners();

    try {
      final facelet = _toFaceletString(_cubeState!);
      var cube = Cube.from(facelet);

      // Parse tokens (handles sequences like "R U R' U'")
      final tokens = _parseMoveString(moveNotation);
      for (final tok in tokens) {
        // Use cuber Move.parse which supports e.g. "R", "R'", "R2", "B", etc.
        final mv = Move.parse(tok);
        cube = cube.move(mv);
      }

      final newFacelet = cube.toString(); // 54-char string U R F D L B
      final arr = newFacelet.split('');
      _cubeState = _faceletCharsToState(arr);

      await Future.delayed(const Duration(milliseconds: 220));
      _currentMove = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error applying move: $e';
      _currentMove = null;
      notifyListeners();
    }
  }

  // --- Scramble locally ---
  Future<void> scrambleCube([int moves = 20]) async {
    _setLoading(true);
    try {
      final rnd = Random();
      final faces = ['R', 'L', 'U', 'D', 'F', 'B'];
      final suffixes = ['', "'", '2'];
      final scramble = <String>[];
      String? lastFace;
      for (int i = 0; i < moves; i++) {
        String face;
        do {
          face = faces[rnd.nextInt(faces.length)];
        } while (face == lastFace);
        lastFace = face;
        final suf = suffixes[rnd.nextInt(suffixes.length)];
        scramble.add(face + suf);
      }

      for (var m in scramble) {
        await applyMove(m);
      }

      _solution = null;
      _currentStepIndex = 0;
      notifyListeners();
    } catch (e) {
      _error = 'Error scrambling: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // --- Playback / step tapping ---
  void startSolutionAnimation() async {
    if (_solution == null || _isAnimating) return;

    _isAnimating = true;
    _currentStepIndex = 0;
    notifyListeners();

    for (var move in _solution!.moves) {
      if (!_isAnimating) break;
      await applyMove(move.notation);
      _currentStepIndex++;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 350));
    }

    _isAnimating = false;
    notifyListeners();
  }

  void stopSolutionAnimation() {
    _isAnimating = false;
    notifyListeners();
  }

  Future<void> tapSolutionStep(int stepIndex) async {
    if (_solution == null) return;
    if (stepIndex != _currentStepIndex) {
      // Only allow the next step
      return;
    }

    final move = _solution!.moves[stepIndex];
    await applyMove(move.notation);
    _currentStepIndex++;
    notifyListeners();
  }

  bool isFaceCaptured(String face) {
    return _capturedFaces[face] ?? false;
  }

  void resetCube() {
    initializeCube();
  }

  // --- DTO <-> facelet utilities (U,R,F,D,L,B) ---
  String _toFaceletString(CubicState dto) {
    final sb = StringBuffer();

    void appendFace(List<List<String>> face) {
      for (int r = 0; r < 3; r++) {
        for (int c = 0; c < 3; c++) {
          final col = face[r][c];
          sb.write(_colorToFacelet(col));
        }
      }
    }

    appendFace(dto.topFace); // U
    appendFace(dto.rightFace); // R
    appendFace(dto.frontFace); // F
    appendFace(dto.bottomFace); // D
    appendFace(dto.leftFace); // L
    appendFace(dto.backFace); // B

    return sb.toString();
  }

  List<String> _toFaceletCharList(CubicState dto) {
    final s = _toFaceletString(dto);
    return s.split('');
  }

  CubicState _faceletCharsToState(List<String> arr) {
    if (arr.length != 54) throw Exception('facelet array must be length 54');
    int idx = 0;
    List<List<String>> readFace() {
      final face = <List<String>>[];
      for (int r = 0; r < 3; r++) {
        final row = <String>[];
        for (int c = 0; c < 3; c++) {
          final ch = arr[idx++];
          row.add(_faceletToColor(ch));
        }
        face.add(row);
      }
      return face;
    }

    return CubicState(
      id: _cubeState?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      topFace: readFace(), // U
      rightFace: readFace(), // R
      frontFace: readFace(), // F
      bottomFace: readFace(), // D
      leftFace: readFace(), // L
      backFace: readFace(), // B
    );
  }

  String _colorToFacelet(String c) {
    switch (c) {
      case 'W':
        return 'U';
      case 'Y':
        return 'D';
      case 'R':
        return 'R';
      case 'O':
        return 'L';
      case 'G':
        return 'F';
      case 'B':
        return 'B';
      default:
        return 'U';
    }
  }

  String _faceletToColor(String ch) {
    switch (ch) {
      case 'U':
        return 'W';
      case 'D':
        return 'Y';
      case 'R':
        return 'R';
      case 'L':
        return 'O';
      case 'F':
        return 'G';
      case 'B':
        return 'B';
      default:
        return 'W';
    }
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
