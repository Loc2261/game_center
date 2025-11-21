import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import '../services/puzzle_api_service.dart';
import '../../../providers/game_provider.dart';
import '../../../models/game_model.dart';

class PuzzleGameScreen extends StatefulWidget {
  final String gameId;
  final String difficulty;
  final String imageUrl;
  final int gridSize;

  const PuzzleGameScreen({
    Key? key,
    required this.gameId,
    required this.difficulty,
    required this.imageUrl,
    required this.gridSize,
  }) : super(key: key);

  @override
  State<PuzzleGameScreen> createState() => _PuzzleGameScreenState();
}

class _PuzzleGameScreenState extends State<PuzzleGameScreen> {
  final PuzzleApiService _api = PuzzleApiService();

  bool _loading = true;
  String _status = "Đang tải ảnh...";
  List<ui.Image> _pieces = [];
  List<int> _order = [];
  int? _firstTapIndex;
  int _moves = 0;
  late Stopwatch _timer;
  bool _completed = false;
  bool _saving = false;

  bool get _isLocalFile => widget.imageUrl.startsWith('/');

  @override
  void initState() {
    super.initState();
    _timer = Stopwatch();
    _preparePuzzle();
  }

  /// 🧩 Chuẩn bị ảnh và chia mảnh puzzle
  Future<void> _preparePuzzle() async {
    setState(() {
      _loading = true;
      _status = "Đang xử lý ảnh...";
      _completed = false;
      _moves = 0;
    });

    try {
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      Uint8List data;
      if (_isLocalFile) {
        data = await File(widget.imageUrl).readAsBytes();
      } else {
        final cacheBuster =
            "${widget.imageUrl}?cb=${DateTime.now().millisecondsSinceEpoch}";
        final response = await http.get(Uri.parse(cacheBuster));
        if (response.statusCode != 200) {
          throw Exception("Không thể tải ảnh (${response.statusCode})");
        }
        data = response.bodyBytes;
      }

      img.Image? decoded = img.decodeImage(data);
      if (decoded == null) throw Exception("Không thể giải mã ảnh");

      // Resize ảnh về tối đa 1080p
      const maxDimension = 1080;
      if (decoded.width > maxDimension || decoded.height > maxDimension) {
        decoded = img.copyResize(
          decoded,
          width: decoded.width > decoded.height ? maxDimension : null,
          height: decoded.height >= decoded.width ? maxDimension : null,
        );
      }

      // Cắt giữa ảnh thành hình vuông
      final int side = min(decoded.width, decoded.height);
      final int offsetX = ((decoded.width - side) / 2).round();
      final int offsetY = ((decoded.height - side) / 2).round();
      decoded = img.copyCrop(
        decoded,
        x: offsetX,
        y: offsetY,
        width: side,
        height: side,
      );

      final n = widget.gridSize;
      final double pieceSize = side / n;

      List<ui.Image> pieces = [];
      for (int row = 0; row < n; row++) {
        for (int col = 0; col < n; col++) {
          final crop = img.copyCrop(
            decoded,
            x: (col * pieceSize).toInt(),
            y: (row * pieceSize).toInt(),
            width: pieceSize.toInt(),
            height: pieceSize.toInt(),
          );
          final bytes = Uint8List.fromList(img.encodeJpg(crop));
          final codec = await ui.instantiateImageCodec(bytes);
          final frame = await codec.getNextFrame();
          pieces.add(frame.image);
        }
      }

      final order = List.generate(pieces.length, (i) => i);
      order.shuffle(Random());

      setState(() {
        _pieces = pieces;
        _order = order;
        _loading = false;
        _status = "Bắt đầu chơi!";
      });

      _timer
        ..reset()
        ..start();
    } catch (e) {
      setState(() {
        _status = "❌ Lỗi khi tải ảnh: $e";
        _loading = false;
      });
    }
  }

  /// 🔄 Khi người chơi bấm 2 mảnh để hoán đổi
  void _onTileTap(int index) {
    if (_completed) return;

    setState(() {
      if (_firstTapIndex == null) {
        _firstTapIndex = index;
        _status = "Chọn mảnh thứ 2 để hoán đổi...";
      } else {
        final first = _firstTapIndex!;
        final second = index;

        final temp = _order[first];
        _order[first] = _order[second];
        _order[second] = temp;

        _moves++;
        _firstTapIndex = null;

        if (_isSolved()) {
          _onGameCompleted();
        } else {
          _status = "Đã hoán đổi ($_moves bước)";
        }
      }
    });
  }

  bool _isSolved() {
    for (int i = 0; i < _order.length; i++) {
      if (_order[i] != i) return false;
    }
    return true;
  }

  /// 🎉 Khi hoàn thành puzzle
  Future<void> _onGameCompleted() async {
    _timer.stop();
    setState(() {
      _completed = true;
      _status = "🎯 Hoàn thành trong $_moves bước!";
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Bạn đã hoàn thành xếp hình!')),
    );
  }

  /// 💾 Gửi điểm lên server (API /Games/puzzle/complete)
  Future<void> _savePuzzleScore() async {
    if (_saving || !_completed) return;
    setState(() => _saving = true);

    // Get the GameProvider from the context
    final gameProvider = Provider.of<GameProvider>(context, listen: false);

    final duration = _timer.elapsed.inSeconds;

    // Create the puzzle-specific result DTO
    final puzzleResult = PuzzleResultDto(
      gameId: widget.gameId,
      difficulty: widget.difficulty,
      gridSize: widget.gridSize,
      moves: _moves,
      durationSeconds: duration,
      imageUrl: widget.imageUrl,
      isCompleted: _completed,
    );

    // Create the unified request object
    final request = GameCompleteRequest(
      gameType: 'Puzzle',
      puzzleResult: puzzleResult,
    );

    try {
      // Call the unified submission method
      await gameProvider.submitGameCompletion(request);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('💾 Score saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to save score: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  /// 🔁 Chơi lại
  Future<void> _restartGame() async {
    _timer.stop();
    await _preparePuzzle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Puzzle ${widget.gridSize}x${widget.gridSize}'),
        backgroundColor: Colors.indigo,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          const SizedBox(height: 10),
          Text(
            _status,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: widget.gridSize,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                  ),
                  itemCount: _pieces.length,
                  itemBuilder: (context, index) {
                    final imgPiece = _pieces[_order[index]];
                    final selected = _firstTapIndex == index;
                    return GestureDetector(
                      onTap: () => _onTileTap(index),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selected
                                ? Colors.redAccent
                                : Colors.white70,
                            width: selected ? 3 : 1,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: RawImage(
                            image: imgPiece,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          /// 🎮 Nút điều khiển
          Padding(
            padding: const EdgeInsets.only(
                top: 20, bottom: 40, left: 8, right: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  flex: 1,
                  child: ElevatedButton.icon(
                    onPressed: _restartGame,
                    icon:
                    const Icon(Icons.refresh, color: Colors.white),
                    label: const Text('Chơi lại',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  flex: 1,
                  child: ElevatedButton.icon(
                    onPressed: _completed && !_saving
                        ? _savePuzzleScore
                        : null,
                    icon: _saving
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Icons.save, color: Colors.white),
                    label: const Text('Lưu điểm',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  flex: 1,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.exit_to_app,
                        color: Colors.white),
                    label: const Text('Thoát',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
