import '../models/position.dart';
import '../models/tetromino.dart';

class SRSData {
  // Wall kick data for JLSTZ pieces
  static const Map<String, List<Position>> jlstzWallKicks = {
    '0->1': [Position(0, 0), Position(-1, 0), Position(-1, 1), Position(0, -2), Position(-1, -2)],
    '1->0': [Position(0, 0), Position(1, 0), Position(1, -1), Position(0, 2), Position(1, 2)],
    '1->2': [Position(0, 0), Position(1, 0), Position(1, -1), Position(0, 2), Position(1, 2)],
    '2->1': [Position(0, 0), Position(-1, 0), Position(-1, 1), Position(0, -2), Position(-1, -2)],
    '2->3': [Position(0, 0), Position(1, 0), Position(1, 1), Position(0, -2), Position(1, -2)],
    '3->2': [Position(0, 0), Position(-1, 0), Position(-1, -1), Position(0, 2), Position(-1, 2)],
    '3->0': [Position(0, 0), Position(-1, 0), Position(-1, -1), Position(0, 2), Position(-1, 2)],
    '0->3': [Position(0, 0), Position(1, 0), Position(1, 1), Position(0, -2), Position(1, -2)],
  };

  // Wall kick data for I piece
  static const Map<String, List<Position>> iWallKicks = {
    '0->1': [Position(0, 0), Position(-2, 0), Position(1, 0), Position(-2, -1), Position(1, 2)],
    '1->0': [Position(0, 0), Position(2, 0), Position(-1, 0), Position(2, 1), Position(-1, -2)],
    '1->2': [Position(0, 0), Position(-1, 0), Position(2, 0), Position(-1, 2), Position(2, -1)],
    '2->1': [Position(0, 0), Position(1, 0), Position(-2, 0), Position(1, -2), Position(-2, 1)],
    '2->3': [Position(0, 0), Position(2, 0), Position(-1, 0), Position(2, 1), Position(-1, -2)],
    '3->2': [Position(0, 0), Position(-2, 0), Position(1, 0), Position(-2, -1), Position(1, 2)],
    '3->0': [Position(0, 0), Position(1, 0), Position(-2, 0), Position(1, -2), Position(-2, 1)],
    '0->3': [Position(0, 0), Position(-1, 0), Position(2, 0), Position(-1, 2), Position(2, -1)],
  };

  static List<Position> getWallKicks(TetrominoType type, int fromRotation, int toRotation) {
    final key = '$fromRotation->$toRotation';
    
    if (type == TetrominoType.I) {
      return iWallKicks[key] ?? [Position(0, 0)];
    } else if (type == TetrominoType.O) {
      return [Position(0, 0)];
    } else {
      return jlstzWallKicks[key] ?? [Position(0, 0)];
    }
  }
}