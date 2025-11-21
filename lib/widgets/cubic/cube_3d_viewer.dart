import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import '../../models/cubic_model.dart';

/// Simple 3D-like cube viewer using transforms + perspective.
/// - Solid faces (no transparency)
/// - Pan to rotate (X/Y)
/// - Rebuilds when cubeState changes
/// - Small overlay shows current step and move
class Cube3DViewer extends StatefulWidget {
  final CubicState cubeState;
  final String? currentMove; // e.g. "R", "R'", "U2"
  final int currentStepIndex; // 0-based
  final int totalSteps;
  final double size; // px

  const Cube3DViewer({
    Key? key,
    required this.cubeState,
    this.currentMove,
    this.currentStepIndex = 0,
    this.totalSteps = 0,
    this.size = 300,
  }) : super(key: key);

  @override
  State<Cube3DViewer> createState() => _Cube3DViewerState();
}

class _Cube3DViewerState extends State<Cube3DViewer> {
  double _rotX = 0.4;
  double _rotY = -0.4;
  double _lastX = 0.0;
  double _lastY = 0.0;

  final Map<String, Color> _tileColors = {
    'W': Colors.white,
    'Y': Colors.yellow,
    'R': Colors.red,
    'O': Colors.orange,
    'G': const Color(0xFF0B8440),
    'B': Colors.blue,
  };

  @override
  Widget build(BuildContext context) {
    final double viewerSize = widget.size;
    // base perspective matrix
    final vm.Matrix4 base = vm.Matrix4.identity();
    base.setEntry(3, 2, 0.001); // perspective
    base.rotateX(_rotX);
    base.rotateY(_rotY);

    return GestureDetector(
      onPanStart: (d) {
        _lastX = d.localPosition.dx;
        _lastY = d.localPosition.dy;
      },
      onPanUpdate: (d) {
        final dx = d.localPosition.dx - _lastX;
        final dy = d.localPosition.dy - _lastY;
        setState(() {
          _rotY += dx * 0.01;
          _rotX += dy * 0.01;
        });
        _lastX = d.localPosition.dx;
        _lastY = d.localPosition.dy;
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // cube center transform (perspective + rotation)
          Transform(
            transform: base,
            alignment: Alignment.center,
            child: SizedBox(
              width: viewerSize,
              height: viewerSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Back
                  _faceTransformed(widget.cubeState.backFace, viewerSize, _backTransform(viewerSize)),
                  // Left
                  _faceTransformed(widget.cubeState.leftFace, viewerSize, _leftTransform(viewerSize)),
                  // Right
                  _faceTransformed(widget.cubeState.rightFace, viewerSize, _rightTransform(viewerSize)),
                  // Top
                  _faceTransformed(widget.cubeState.topFace, viewerSize, _topTransform(viewerSize)),
                  // Bottom
                  _faceTransformed(widget.cubeState.bottomFace, viewerSize, _bottomTransform(viewerSize)),
                  // Front (draw last so it's visually on top when facing camera)
                  _faceTransformed(widget.cubeState.frontFace, viewerSize, _frontTransform(viewerSize)),
                ],
              ),
            ),
          ),

          // Current move / step overlay
          if (widget.currentMove != null || widget.totalSteps > 0)
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.currentMove != null) ...[
                        const Icon(Icons.rotate_right, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text('Move: ${widget.currentMove}', style: const TextStyle(color: Colors.white)),
                        const SizedBox(width: 16),
                      ],
                      if (widget.totalSteps > 0)
                        Text('Step ${widget.currentStepIndex + 1}/${widget.totalSteps}', style: const TextStyle(color: Colors.white)),
                      if (widget.totalSteps == 0 && widget.currentMove == null)
                        const Text('Cube', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _faceTransformed(List<List<String>> face, double viewerSize, vm.Matrix4 local) {
    // Compose rotation (already applied to parent) + local
    final vm.Matrix4 comp = vm.Matrix4.copy(local);
    return Transform(
      alignment: Alignment.center,
      transform: comp,
      child: _faceWidget(face, viewerSize / 3), // pass face size area
    );
  }

  Widget _faceWidget(List<List<String>> face, double faceSize) {
    // No inner GridView — fixed Rows & Columns to avoid layout overflow
    final double cellSize = faceSize / 3;
    return Container(
      width: faceSize,
      height: faceSize,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black87, width: 1.8),
        borderRadius: BorderRadius.circular(6),
        color: Colors.black12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (r) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (c) {
              final code = (face.length > r && face[r].length > c) ? face[r][c] : 'W';
              final color = _tileColors[code] ?? Colors.grey;
              return Container(
                width: cellSize,
                height: cellSize,
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(color: Colors.black87, width: 0.8),
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  // Local transforms for faces: translate + rotation relative to cube center
  vm.Matrix4 _frontTransform(double viewerSize) {
    final m = vm.Matrix4.identity();
    m.translate(0.0, 0.0, viewerSize / 2.0);
    return m;
  }

  vm.Matrix4 _backTransform(double viewerSize) {
    final m = vm.Matrix4.identity();
    m.translate(0.0, 0.0, -viewerSize / 2.0);
    m.rotateY(vm.radians(180));
    return m;
  }

  vm.Matrix4 _leftTransform(double viewerSize) {
    final m = vm.Matrix4.identity();
    m.translate(-viewerSize / 2.0, 0.0, 0.0);
    m.rotateY(vm.radians(-90));
    return m;
  }

  vm.Matrix4 _rightTransform(double viewerSize) {
    final m = vm.Matrix4.identity();
    m.translate(viewerSize / 2.0, 0.0, 0.0);
    m.rotateY(vm.radians(90));
    return m;
  }

  vm.Matrix4 _topTransform(double viewerSize) {
    final m = vm.Matrix4.identity();
    m.translate(0.0, -viewerSize / 2.0, 0.0);
    m.rotateX(vm.radians(-90));
    return m;
  }

  vm.Matrix4 _bottomTransform(double viewerSize) {
    final m = vm.Matrix4.identity();
    m.translate(0.0, viewerSize / 2.0, 0.0);
    m.rotateX(vm.radians(90));
    return m;
  }
}
