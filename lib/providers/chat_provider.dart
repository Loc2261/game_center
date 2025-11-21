// import 'package:flutter/material.dart';
// import '../services/friend_api_service.dart';
// import '../models/user_model.dart';
//
// class FriendProvider with ChangeNotifier {
//   final FriendApiService _apiService;
//
//   List<User> _friends = [];
//   List<User> _pendingRequests = [];
//   bool _isLoading = false;
//   String? _errorMessage;
//
//   List<User> get friends => _friends;
//   List<User> get pendingRequests => _pendingRequests;
//   bool get isLoading => _isLoading;
//   String? get errorMessage => _errorMessage;
//
//   // SỬA: Constructor chỉ nhận 1 argument
//   FriendProvider(this._apiService);
//
//   // Helper để thực thi các hành động và quản lý state loading/error
//   Future<void> _execute(Future<void> Function() action, {bool rethrowError = false}) async {
//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();
//     try {
//       await action();
//     } on Exception catch (e) {
//       _errorMessage = e.toString().replaceFirst('Exception: ', '');
//       if (rethrowError) rethrow;
//     } catch (e) {
//       _errorMessage = 'An unexpected error occurred.';
//       if (rethrowError) rethrow;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   // Tải tất cả dữ liệu (bạn bè và lời mời) cùng lúc
//   Future<void> fetchAll() async {
//     await _execute(() async {
//       // SỬA: Không cần truyền token, service đã xử lý
//       final results = await Future.wait([
//         _apiService.getFriends(),
//         _apiService.getPendingRequests(),
//       ]);
//       _friends = results[0];
//       _pendingRequests = results[1];
//     });
//   }
//
//   Future<void> acceptFriendRequest(int friendId) async {
//     await _execute(() async {
//       // SỬA: Không cần truyền token, service đã xử lý
//       await _apiService.acceptFriendRequest(friendId);
//       await fetchAll(); // Tự động tải lại toàn bộ danh sách
//     }, rethrowError: true);
//   }
//
//   Future<void> rejectFriendRequest(int friendId) async {
//     await _execute(() async {
//       // SỬA: Không cần truyền token, service đã xử lý
//       await _apiService.rejectFriendRequest(friendId);
//       await fetchAll(); // Tự động tải lại toàn bộ danh sách
//     }, rethrowError: true);
//   }
//
//   Future<void> removeFriend(int friendId) async {
//     await _execute(() async {
//       // SỬA: Không cần truyền token, service đã xử lý
//       await _apiService.removeFriend(friendId);
//       await fetchAll(); // Tự động tải lại toàn bộ danh sách
//     }, rethrowError: true);
//   }
//
//   void clearError() {
//     _errorMessage = null;
//     notifyListeners();
//   }
// }