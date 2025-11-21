// import 'package:flutter/material.dart';
// import '../services/auth_service.dart';
// import '../models/user_model.dart';
//
// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({Key? key}) : super(key: key);
//
//   @override
//   _ProfileScreenState createState() => _ProfileScreenState();
// }
//
// class _ProfileScreenState extends State<ProfileScreen> {
//   UserProfile? _userProfile;
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserProfile();
//   }
//
//   Future<void> _loadUserProfile() async {
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       final profile = await AuthService.getUserProfile();
//       setState(() {
//         _userProfile = profile;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error loading profile: $e')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Profile')),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _userProfile == null
//           ? const Center(child: Text('Failed to load profile'))
//           : Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             const CircleAvatar(
//               radius: 50,
//               child: Icon(Icons.person, size: 50),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               _userProfile!.username,
//               style: Theme.of(context).textTheme.headline5,
//             ),
//             Text(_userProfile!.email),
//             const SizedBox(height: 20),
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   children: [
//                     _buildStatItem('Total Games', _userProfile!.totalGamesPlayed.toString()),
//                     _buildStatItem('Total Score', _userProfile!.totalScore.toString()),
//                     _buildStatItem('Member Since', _userProfile!.createdAt.year.toString()),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStatItem(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
//           Text(value),
//         ],
//       ),
//     );
//   }
// }