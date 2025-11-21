import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// PuzzleApiService - robust startPuzzle with offline fallback.
///
/// If your configured backend is unreachable (DNS/SocketException),
/// this will return a local "success" payload so the UI can start
/// a local puzzle session (no network required).
class PuzzleApiService {
  final String baseUrl;

  /// Supply your real baseUrl in production. Keep the default empty to
  /// force local fallback (useful for local testing without a backend).
  PuzzleApiService({this.baseUrl = ''});

  /// Start puzzle on backend or fall back to local session on error.
  Future<Map<String, dynamic>> startPuzzle(String difficulty, String imagePath, {String? token}) async {
    // If baseUrl is empty or clearly not configured, skip network attempt:
    if (baseUrl.trim().isEmpty || baseUrl.contains('your.api.endpoint')) {
      return _localStartResponse(difficulty, imagePath);
    }

    final uri = Uri.parse('$baseUrl/games/puzzle/start');
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) headers['Authorization'] = 'Bearer $token';

    try {
      final body = json.encode({
        'difficulty': difficulty,
        'imageUrl': imagePath,
      });

      final resp = await http.post(uri, body: body, headers: headers).timeout(const Duration(seconds: 8));
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final decoded = json.decode(resp.body);
        // Ensure we return a Map<String, dynamic>
        if (decoded is Map<String, dynamic>) return decoded;
        return {'success': false, 'message': 'Invalid server response.'};
      } else {
        // return server message if available
        final decoded = resp.body.isNotEmpty ? json.decode(resp.body) : null;
        final msg = (decoded is Map && decoded['message'] != null) ? decoded['message'] : 'Server error ${resp.statusCode}';
        return {'success': false, 'message': msg};
      }
    } on SocketException catch (e) {
      // network unreachable -> fallback local session
      return _localStartResponse(difficulty, imagePath, note: 'Network unreachable: $e');
    } on HttpException catch (e) {
      return _localStartResponse(difficulty, imagePath, note: 'HTTP error: $e');
    } on FormatException catch (e) {
      return _localStartResponse(difficulty, imagePath, note: 'Response format error: $e');
    } on Exception catch (e) {
      // any other error -> local fallback, but keep the message for debugging
      return _localStartResponse(difficulty, imagePath, note: 'Exception: $e');
    }
  }

  // Local fallback response format the UI expects:
  Map<String, dynamic> _localStartResponse(String difficulty, String imagePath, {String? note}) {
    final id = 'local-${DateTime.now().millisecondsSinceEpoch}';
    return {
      'success': true,
      'data': {
        'id': id,
        'difficulty': difficulty,
        'imageUrl': imagePath,
        // additional metadata the server might normally return:
        'createdAt': DateTime.now().toIso8601String(),
        'note': note ?? 'started locally'
      }
    };
  }
}