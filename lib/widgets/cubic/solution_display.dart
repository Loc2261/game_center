import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/cubic_model.dart';

class SolutionDisplay extends StatefulWidget {
  final CubicSolution solution;
  final Function(CubicMove) onStepTap;
  final VoidCallback onPlayAnimation;
  final VoidCallback onStopAnimation;
  final bool isAnimating;

  const SolutionDisplay({
    Key? key,
    required this.solution,
    required this.onStepTap,
    required this.onPlayAnimation,
    required this.onStopAnimation,
    required this.isAnimating,
  }) : super(key: key);

  @override
  _SolutionDisplayState createState() => _SolutionDisplayState();
}

class _SolutionDisplayState extends State<SolutionDisplay> {
  int _currentStepIndex = 0;
  bool _showNotation = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with solution info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF9333EA),
                const Color(0xFF6B46C1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.solution.solutionType == 'optimal'
                            ? 'Optimal Solution'
                            : 'Ergonomic Solution',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.solution.moveCount} moves • ~${widget.solution.estimatedSeconds}s',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  // Play/Pause button
                  IconButton(
                    onPressed: widget.isAnimating
                        ? widget.onStopAnimation
                        : widget.onPlayAnimation,
                    icon: Icon(
                      widget.isAnimating ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 32,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Toggle between notation and steps
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => setState(() => _showNotation = true),
                      icon: const Icon(Icons.text_fields, size: 20),
                      label: const Text('Notation'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _showNotation ? Colors.white : Colors.white60,
                        side: BorderSide(
                          color: _showNotation ? Colors.white : Colors.white30,
                        ),
                        backgroundColor: _showNotation
                            ? Colors.white.withOpacity(0.2)
                            : Colors.transparent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => setState(() => _showNotation = false),
                      icon: const Icon(Icons.format_list_numbered, size: 20),
                      label: const Text('Steps'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: !_showNotation ? Colors.white : Colors.white60,
                        side: BorderSide(
                          color: !_showNotation ? Colors.white : Colors.white30,
                        ),
                        backgroundColor: !_showNotation
                            ? Colors.white.withOpacity(0.2)
                            : Colors.transparent,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Content
        Expanded(
          child: _showNotation
              ? _buildNotationView()
              : _buildStepsView(),
        ),
      ],
    );
  }

  Widget _buildNotationView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.code, color: Colors.purple),
                      const SizedBox(width: 8),
                      const Text(
                        'Solution Notation',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: widget.solution.notation),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Notation copied to clipboard'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy, size: 20),
                        tooltip: 'Copy notation',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: SelectableText(
                      widget.solution.notation,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Legend
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.help_outline, color: Colors.purple),
                      SizedBox(width: 8),
                      Text(
                        'Notation Guide',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildNotationLegend(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.solution.moves.length,
      itemBuilder: (context, index) {
        final move = widget.solution.moves[index];
        final isCurrentStep = index == _currentStepIndex;
        
        return Card(
          elevation: isCurrentStep ? 8 : 2,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isCurrentStep
                  ? const Color(0xFF9333EA)
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: InkWell(
            onTap: () {
              setState(() => _currentStepIndex = index);
              widget.onStepTap(move);
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Step number
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isCurrentStep
                          ? const Color(0xFF9333EA)
                          : Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isCurrentStep ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Move notation
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple[50],
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.purple[200]!),
                    ),
                    child: Text(
                      move.notation,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Description
                  Expanded(
                    child: Text(
                      move.description,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                  
                  // Play button for individual move
                  IconButton(
                    onPressed: () => widget.onStepTap(move),
                    icon: const Icon(Icons.play_circle_outline),
                    color: const Color(0xFF9333EA),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotationLegend() {
    return Column(
      children: [
        _buildLegendRow('R', 'Right face clockwise'),
        _buildLegendRow("R'", 'Right face counter-clockwise'),
        _buildLegendRow('R2', 'Right face 180°'),
        _buildLegendRow('L', 'Left face clockwise'),
        _buildLegendRow('U', 'Up (top) face clockwise'),
        _buildLegendRow('D', 'Down (bottom) face clockwise'),
        _buildLegendRow('F', 'Front face clockwise'),
        _buildLegendRow('B', 'Back face clockwise'),
        _buildLegendRow('M', 'Middle slice (between L and R)'),
        _buildLegendRow('E', 'Equatorial slice (between U and D)'),
        _buildLegendRow('S', 'Standing slice (between F and B)'),
      ],
    );
  }

  Widget _buildLegendRow(String notation, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 40,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.purple[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              notation,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}