import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/puzzle_api_service.dart';
import 'puzzle_game_screen.dart';

class PuzzleSetupScreen extends StatefulWidget {
  const PuzzleSetupScreen({Key? key}) : super(key: key);

  @override
  State<PuzzleSetupScreen> createState() => _PuzzleSetupScreenState();
}

class _PuzzleSetupScreenState extends State<PuzzleSetupScreen> {
  final _imageUrlController = TextEditingController();
  final _picker = ImagePicker();
  File? _selectedImage;
  String _selectedDifficulty = 'easy';
  bool _isLoading = false;

  final _api = PuzzleApiService(baseUrl: 'https://your.api.endpoint');

  Future<void> _pickImageFromGallery() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
        _imageUrlController.clear();
      });
    }
  }

  Future<void> _startGame() async {
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    String imageSource = _selectedImage != null ? _selectedImage!.path : _imageUrlController.text.trim();

    try {
      final response = await _api.startPuzzle(_selectedDifficulty, imageSource, token: token);
      setState(() => _isLoading = false);

      if (response['success'] == true) {
        final data = response['data'] ?? {};
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PuzzleGameScreen(
              gameId: data['id']?.toString() ?? 'local-game',
              difficulty: _selectedDifficulty,
              imageUrl: imageSource,
              gridSize: _selectedDifficulty == 'easy' ? 3 : _selectedDifficulty == 'medium' ? 4 : 5,
            ),
          ),
        );
      } else {
        final message = response['message'] ?? 'Lỗi không xác định';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không thể bắt đầu trò chơi: $message')));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _selectedImage != null || _imageUrlController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt Puzzle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (hasImage)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _selectedImage != null
                      ? Image.file(_selectedImage!, fit: BoxFit.cover)
                      : Image.network(_imageUrlController.text.trim(), fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey)),
                ),
              )
            else
              GestureDetector(
                onTap: _pickImageFromGallery,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey[200]),
                  child: const Center(child: Text('Tap to choose image from gallery')),
                ),
              ),
            const SizedBox(height: 12),
            TextField(controller: _imageUrlController, decoration: const InputDecoration(labelText: 'Image URL')),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: ElevatedButton(onPressed: _isLoading ? null : _startGame, child: _isLoading ? const CircularProgressIndicator() : const Text('Start'))),
              ],
            )
          ],
        ),
      ),
    );
  }
}
