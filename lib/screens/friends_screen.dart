// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../models/user_model.dart';
// import '../providers/friend_provider.dart';
// import '../widgets/common/error_widget.dart';
// import '../widgets/common/loading_widget.dart';
//
// class FriendsScreen extends StatefulWidget {
//   const FriendsScreen({super.key});
//
//   @override
//   State<FriendsScreen> createState() => _FriendsScreenState();
// }
//
// class _FriendsScreenState extends State<FriendsScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<FriendProvider>().fetchAll();
//     });
//   }
//
//   Future<void> _handleAction(Future<void> Function() action, String successMessage) async {
//     try {
//       await action();
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(successMessage),
//             backgroundColor: Colors.green,
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Lỗi: ${e.toString()}'),
//             backgroundColor: Colors.red,
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         backgroundColor: Theme.of(context).colorScheme.background,
//         appBar: AppBar(
//           title: const Text('Bạn Bè'),
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           bottom: TabBar(
//             indicatorColor: Theme.of(context).primaryColor,
//             labelColor: Theme.of(context).primaryColor,
//             unselectedLabelColor: Colors.grey,
//             tabs: const [
//               Tab(icon: Icon(Icons.people), text: 'Bạn Bè'),
//               Tab(icon: Icon(Icons.person_add), text: 'Lời Mời'),
//             ],
//           ),
//         ),
//         body: Consumer<FriendProvider>(
//           builder: (context, provider, child) {
//             if (provider.isLoading && provider.friends.isEmpty && provider.pendingRequests.isEmpty) {
//               return const LoadingWidget(message: 'Đang tải danh sách bạn bè...');
//             }
//
//             if (provider.errorMessage != null && provider.friends.isEmpty && provider.pendingRequests.isEmpty) {
//               return AppErrorWidget(
//                   errorMessage: provider.errorMessage!,
//                   onRetry: () => provider.fetchAll()
//               );
//             }
//
//             return RefreshIndicator(
//               onRefresh: () => provider.fetchAll(),
//               child: TabBarView(
//                 children: [
//                   _buildFriendsList(provider),
//                   _buildRequestsList(provider),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFriendsList(FriendProvider provider) {
//     if (provider.friends.isEmpty) {
//       return _buildEmptyState(
//         icon: Icons.people_outline,
//         message: 'Bạn chưa có người bạn nào',
//         subtitle: 'Hãy kết bạn để thêm bạn bè vào danh sách!',
//       );
//     }
//
//     return ListView.separated(
//       padding: const EdgeInsets.all(16),
//       itemCount: provider.friends.length,
//       separatorBuilder: (context, index) => const SizedBox(height: 8),
//       itemBuilder: (context, index) {
//         final friend = provider.friends[index];
//         return _buildFriendCard(friend, provider);
//       },
//     );
//   }
//
//   Widget _buildRequestsList(FriendProvider provider) {
//     if (provider.pendingRequests.isEmpty) {
//       return _buildEmptyState(
//         icon: Icons.person_add_disabled,
//         message: 'Không có lời mời kết bạn',
//         subtitle: 'Khi có lời mời, nó sẽ xuất hiện tại đây',
//       );
//     }
//
//     return ListView.separated(
//       padding: const EdgeInsets.all(16),
//       itemCount: provider.pendingRequests.length,
//       separatorBuilder: (context, index) => const SizedBox(height: 8),
//       itemBuilder: (context, index) {
//         final request = provider.pendingRequests[index];
//         return _buildRequestCard(request, provider);
//       },
//     );
//   }
//
//   Widget _buildFriendCard(User friend, FriendProvider provider) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: ListTile(
//         contentPadding: const EdgeInsets.all(16),
//         leading: CircleAvatar(
//           backgroundColor: Theme.of(context).primaryColor,
//           radius: 24,
//           child: Text(
//             friend.username[0].toUpperCase(),
//             style: const TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         title: Text(
//           friend.username,
//           style: const TextStyle(fontWeight: FontWeight.w600),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 4),
//             Row(
//               children: [
//                 Icon(Icons.emoji_events, size: 16, color: Colors.amber),
//                 const SizedBox(width: 4),
//                 Text(
//                   '${friend.totalScore} điểm',
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         trailing: IconButton(
//           icon: Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Colors.red.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(Icons.person_remove, color: Colors.red, size: 20),
//           ),
//           onPressed: () => _showRemoveFriendDialog(friend, provider),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildRequestCard(User request, FriendProvider provider) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: ListTile(
//         contentPadding: const EdgeInsets.all(16),
//         leading: CircleAvatar(
//           backgroundColor: Colors.orange,
//           radius: 24,
//           child: Text(
//             request.username[0].toUpperCase(),
//             style: const TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         title: Text(
//           request.username,
//           style: const TextStyle(fontWeight: FontWeight.w600),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 4),
//             Row(
//               children: [
//                 Icon(Icons.emoji_events, size: 16, color: Colors.amber),
//                 const SizedBox(width: 4),
//                 Text(
//                   '${request.totalScore} điểm',
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 4),
//             Text(
//               'Muốn kết bạn với bạn',
//               style: TextStyle(
//                 color: Colors.orange[700],
//                 fontSize: 12,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             IconButton(
//               icon: Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.green.withOpacity(0.1),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(Icons.check, color: Colors.green, size: 20),
//               ),
//               onPressed: () => _handleAction(
//                     () => provider.acceptFriendRequest(request.id),
//                 'Đã chấp nhận lời mời kết bạn!',
//               ),
//             ),
//             IconButton(
//               icon: Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.red.withOpacity(0.1),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(Icons.close, color: Colors.red, size: 20),
//               ),
//               onPressed: () => _handleAction(
//                     () => provider.rejectFriendRequest(request.id),
//                 'Đã từ chối lời mời kết bạn',
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEmptyState({
//     required IconData icon,
//     required String message,
//     String? subtitle,
//   }) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: Colors.grey.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 icon,
//                 size: 64,
//                 color: Colors.grey[400],
//               ),
//             ),
//             const SizedBox(height: 24),
//             Text(
//               message,
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                 color: Colors.grey[700],
//               ),
//               textAlign: TextAlign.center,
//             ),
//             if (subtitle != null) ...[
//               const SizedBox(height: 8),
//               Text(
//                 subtitle,
//                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                   color: Colors.grey[600],
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showRemoveFriendDialog(User friend, FriendProvider provider) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Xóa bạn bè'),
//         content: Text('Bạn có chắc muốn xóa ${friend.username} khỏi danh sách bạn bè?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(ctx).pop(),
//             child: const Text('Hủy'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.of(ctx).pop();
//               _handleAction(
//                     () => provider.removeFriend(friend.id),
//                 'Đã xóa ${friend.username} khỏi danh sách bạn bè',
//               );
//             },
//             child: const Text(
//               'Xóa',
//               style: TextStyle(color: Colors.red),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }