// lib/widgets/cubic/cube_face_input.dart
import 'package:flutter/material.dart';
import '../../models/cubic_model.dart';

class CubeFaceInput extends StatefulWidget {
  final CubicState cubeState;
  final Function(String face, int row, int col, String color) onColorChanged;

  const CubeFaceInput({
    Key? key,
    required this.cubeState,
    required this.onColorChanged,
  }) : super(key: key);

  @override
  _CubeFaceInputState createState() => _CubeFaceInputState();
}

class _CubeFaceInputState extends State<CubeFaceInput> {
  String _selectedFace = 'front';
  String _selectedColor = 'W';

  final Map<String, Color> colorMap = {
    'W': Colors.white,
    'Y': const Color(0xFFFFEB3B),
    'R': Colors.red,
    'O': Colors.orange,
    'G': const Color(0xFF00C853),
    'B': Colors.blue,
  };

  final Map<String, String> faceLabels = {
    'front': 'Front (Green)',
    'back': 'Back (Blue)',
    'left': 'Left (Orange)',
    'right': 'Right (Red)',
    'top': 'Top (White)',
    'bottom': 'Bottom (Yellow)',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Face selector
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: faceLabels.length,
            itemBuilder: (context, index) {
              final face = faceLabels.keys.elementAt(index);
              final label = faceLabels[face]!;
              final isSelected = _selectedFace == face;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(label.split(' ')[0]),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedFace = face);
                  },
                  selectedColor: Colors.purple,
                  backgroundColor: Colors.grey[800],
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Color palette
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: colorMap.entries.map((entry) {
            return GestureDetector(
              onTap: () => setState(() => _selectedColor = entry.key),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: entry.value,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _selectedColor == entry.key ? Colors.purple : Colors.black,
                    width: _selectedColor == entry.key ? 3 : 1,
                  ),
                  boxShadow: [
                    if (_selectedColor == entry.key)
                      BoxShadow(color: Colors.purple.withOpacity(0.4), blurRadius: 8, spreadRadius: 2),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        // Face grid
        Center(
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2), borderRadius: BorderRadius.circular(8)),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 2, crossAxisSpacing: 2),
              itemCount: 9,
              itemBuilder: (context, index) {
                final row = index ~/ 3;
                final col = index % 3;
                final currentColor = _getCurrentFaceColor(row, col);

                return GestureDetector(
                  onTap: () {
                    widget.onColorChanged(_selectedFace, row, col, _selectedColor);
                    setState(() {});
                  },
                  child: Container(
                    color: colorMap[currentColor],
                    child: Center(
                      child: Text(
                        currentColor,
                        style: TextStyle(
                          color: currentColor == 'W' || currentColor == 'Y' ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  String _getCurrentFaceColor(int row, int col) {
    switch (_selectedFace) {
      case 'front':
        return widget.cubeState.frontFace[row][col];
      case 'back':
        return widget.cubeState.backFace[row][col];
      case 'left':
        return widget.cubeState.leftFace[row][col];
      case 'right':
        return widget.cubeState.rightFace[row][col];
      case 'top':
        return widget.cubeState.topFace[row][col];
      case 'bottom':
        return widget.cubeState.bottomFace[row][col];
      default:
        return 'W';
    }
  }
}
