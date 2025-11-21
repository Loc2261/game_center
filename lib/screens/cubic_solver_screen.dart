import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/cubic_solver_provider.dart';
import '../widgets/cubic/cube_3d_viewer.dart';
import '../widgets/cubic/cube_face_input.dart';
import '../widgets/cubic/solution_display.dart'; // keep your solution widget


class CubicSolverScreen extends StatefulWidget {
  const CubicSolverScreen({Key? key}) : super(key: key);

  @override
  _CubicSolverScreenState createState() => _CubicSolverScreenState();
}

class _CubicSolverScreenState extends State<CubicSolverScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  String _solutionType = 'optimal';
  bool _showingSolution = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<CubicSolverProvider>(context, listen: false);
      provider.initializeCube();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, String face) async {
    try {
      final XFile? image = await _picker.pickImage(source: source, preferredCameraDevice: CameraDevice.rear);
      if (image != null) {
        final provider = Provider.of<CubicSolverProvider>(context, listen: false);
        await provider.processImage(image.path, face);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Face captured successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error capturing image: $e'), backgroundColor: Colors.red));
    }
  }

  void _showCaptureChoice(String face) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.cyan),
                title: const Text('Take photo', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera, face);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo, color: Colors.cyan),
                title: const Text('Choose from gallery', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery, face);
                },
              ),
              ListTile(
                leading: const Icon(Icons.close, color: Colors.grey),
                title: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _solveCube() async {
    final provider = Provider.of<CubicSolverProvider>(context, listen: false);

    if (!provider.validateCubeState()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid cube state. Please check all faces.'), backgroundColor: Colors.orange));
      return;
    }

    await provider.solveCube(_solutionType);
    setState(() {
      _showingSolution = true;
    });

    _tabController.animateTo(2);
    _animationController.forward();
  }

  void _resetCube() {
    final provider = Provider.of<CubicSolverProvider>(context, listen: false);
    provider.resetCube();
    setState(() {
      _showingSolution = false;
    });
    _animationController.reset();
  }

  void _scrambleCube() async {
    final provider = Provider.of<CubicSolverProvider>(context, listen: false);
    await provider.scrambleCube();
    _tabController.animateTo(1);
  }

  Future<void> _captureAndProcessImage(String face) async {
    _showCaptureChoice(face);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Rubik\'s Cube Solver'),
        backgroundColor: const Color(0xFF1A1A1A),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF007991), Color(0xFF78FFD6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _resetCube, tooltip: 'Reset Cube'),
          IconButton(icon: const Icon(Icons.shuffle), onPressed: _scrambleCube, tooltip: 'Scramble Cube'),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.input), text: 'Input'),
            Tab(icon: Icon(Icons.view_in_ar), text: '3D View'),
            Tab(icon: Icon(Icons.play_arrow), text: 'Solution'),
          ],
        ),
      ),
      body: SafeArea(
        child: Consumer<CubicSolverProvider>(
          builder: (context, provider, child) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildInputTab(provider),
                _build3DViewTab(provider),
                _buildSolutionTab(provider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInputTab(CubicSolverProvider provider) {
    return Container(
      color: Colors.black,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Card(
            color: const Color(0xFF1A1A1A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.cyan[800]!, width: 1)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.camera_alt, color: Colors.cyan),
                  const SizedBox(width: 8),
                  const Text('Capture Cube Faces', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Spacer(),
                  TextButton.icon(onPressed: _showHelpDialog, icon: const Icon(Icons.help_outline, size: 20, color: Colors.cyan), label: const Text('Help', style: TextStyle(color: Colors.cyan))),
                ]),
                const SizedBox(height: 16),
                const Text('Take a photo of each face or manually input colors:', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 20),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    _buildFaceCaptureButton('Front', Colors.green, provider),
                    _buildFaceCaptureButton('Back', Colors.blue, provider),
                    _buildFaceCaptureButton('Left', Colors.orange, provider),
                    _buildFaceCaptureButton('Right', Colors.red, provider),
                    _buildFaceCaptureButton('Top', Colors.white, provider),
                    _buildFaceCaptureButton('Bottom', Colors.yellow, provider),
                  ],
                ),
              ]),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            color: const Color(0xFF1A1A1A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.cyan[800]!, width: 1)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Row(children: [Icon(Icons.edit, color: Colors.cyan), SizedBox(width: 8), Text('Manual Color Input', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))]),
                const SizedBox(height: 16),
                CubeFaceInput(cubeState: provider.cubeState, onColorChanged: provider.updateFaceColor),
              ]),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            color: const Color(0xFF1A1A1A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.cyan[800]!, width: 1)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Solution Type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 12),
                RadioListTile<String>(
                  title: const Text('Optimal (Fewer moves)', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Optimal solver - fewer moves', style: TextStyle(color: Colors.grey)),
                  value: 'optimal',
                  groupValue: _solutionType,
                  onChanged: (value) => setState(() => _solutionType = value!),
                  activeColor: Colors.cyan,
                ),
                RadioListTile<String>(
                  title: const Text('Ergonomic (Comfortable)', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Ergonomic solver - easier hand movement', style: TextStyle(color: Colors.grey)),
                  value: 'ergonomic',
                  groupValue: _solutionType,
                  onChanged: (value) => setState(() => _solutionType = value!),
                  activeColor: Colors.cyan,
                ),
              ]),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: provider.isLoading ? null : _solveCube,
              icon: provider.isLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                  : const Icon(Icons.play_arrow, size: 28),
              label: Text(provider.isLoading ? 'Solving...' : 'Solve Cube', style: const TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BCD4), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _build3DViewTab(CubicSolverProvider provider) {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          Expanded(
            child: Card(
              color: const Color(0xFF0A0A0A),
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.cyan[800]!, width: 1)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                // Removed the undefined onRotate named parameter; pass only supported names
                child: Cube3DViewer(
                  cubeState: provider.cubeState,
                  currentMove: provider.currentMove,
                  currentStepIndex: provider.currentStepIndex,
                  totalSteps: provider.totalSteps,
                  size: 340,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 140,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF1A1A1A), boxShadow: [BoxShadow(color: Colors.cyan.withOpacity(0.1), blurRadius: 10, offset: Offset(0, -5))]),
              child: Column(children: [
                const Text('Rotate Cube', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  _buildRotateButton('R', provider),
                  _buildRotateButton('L', provider),
                  _buildRotateButton('U', provider),
                  _buildRotateButton('D', provider),
                  _buildRotateButton('F', provider),
                  _buildRotateButton('B', provider),
                ]),
                const SizedBox(height: 8),
                Text('Tap to rotate clockwise, long press for counter-clockwise', style: TextStyle(fontSize: 12, color: Colors.grey[400]), textAlign: TextAlign.center),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRotateButton(String move, CubicSolverProvider provider) {
    return GestureDetector(
      onTap: () => provider.applyMove(move),
      onLongPress: () => provider.applyMove("$move'"),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(color: const Color(0xFF00BCD4), borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.cyan.withOpacity(0.3), blurRadius: 4, offset: Offset(0, 2))]),
        child: Center(child: Text(move, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
      ),
    );
  }

  Widget _buildFaceCaptureButton(String face, Color color, CubicSolverProvider provider) {
    final bool isCaptured = provider.isFaceCaptured(face);
    return Material(
      elevation: isCaptured ? 2 : 4,
      borderRadius: BorderRadius.circular(12),
      color: isCaptured ? color.withOpacity(0.9) : const Color(0xFF2A2A2A),
      child: InkWell(
        onTap: () => _captureAndProcessImage(face),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: isCaptured ? color : Colors.grey[600]!, width: 2)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(isCaptured ? Icons.check_circle : Icons.camera_alt, color: isCaptured ? Colors.white : color, size: 28),
            const SizedBox(height: 4),
            Text(face, style: TextStyle(color: isCaptured ? Colors.white : Colors.grey[300], fontWeight: FontWeight.w600, fontSize: 12)),
          ]),
        ),
      ),
    );
  }

  Widget _buildSolutionTab(CubicSolverProvider provider) {
    if (!_showingSolution || provider.solution == null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.lightbulb_outline, size: 80, color: Colors.grey[600]),
            const SizedBox(height: 16),
            const Text('No solution yet', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text('Input your cube and tap Solve to see the solution', style: TextStyle(fontSize: 14, color: Colors.grey[400]), textAlign: TextAlign.center),
          ]),
        ),
      );
    }

    // SolutionDisplay expects an `int` index on onStepTap — pass the index and enforce gating
    return SolutionDisplay(
      solution: provider.solution!,
      // SolutionDisplay expects a CubicMove; we accept it synchronously and run async work inside.
      onStepTap: (move) {
        // run async work inside an IIFE so the callback remains synchronous (returns void)
        () async {
          final idx = provider.solution!.moves.indexWhere((m) =>
              m.stepNumber == move.stepNumber && m.move == move.move);
          if (idx < 0) return;

          // only allow the next step
          if (idx != provider.currentStepIndex) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('You can only perform the next step.'),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }

          // apply the step (this is async)
          await provider.tapSolutionStep(idx);

          // switch to 3D view so they can see the move
          _tabController.animateTo(1);
        }();
      },
      onPlayAnimation: () {
        provider.startSolutionAnimation();
      },
      onStopAnimation: () {
        provider.stopSolutionAnimation();
      },
      isAnimating: provider.isAnimating,
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('How to Use', style: TextStyle(color: Colors.white)),
        content: const SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text('1. Capture Faces:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.cyan)),
            Text('   • Hold the cube with one color facing the camera', style: TextStyle(color: Colors.grey)),
            Text('   • Ensure good lighting', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 12),
            Text('2. Manual Input:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.cyan)),
            Text('   • Tap on each square to select its color', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 12),
            Text('3. Solution Types:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.cyan)),
            Text('   • Optimal: Fewer moves but harder', style: TextStyle(color: Colors.grey)),
            Text('   • Ergonomic: More moves but easier to execute', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 12),
            Text('Notation:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.cyan)),
            Text('   • R = Right, L = Left, U = Up, D = Down', style: TextStyle(color: Colors.grey)),
            Text("   • F = Front, B = Back", style: TextStyle(color: Colors.grey)),
            Text("   • ' = Counter-clockwise, 2 = 180°", style: TextStyle(color: Colors.grey)),
          ]),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Got it', style: TextStyle(color: Colors.cyan)))],
      ),
    );
  }
}
