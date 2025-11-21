import 'package:flutter/foundation.dart';

@immutable
class AuthRequest {
  final String username;
  final String password;

  const AuthRequest({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }

  @override
  String toString() => 'AuthRequest(username: $username)';
}

@immutable
class AuthResponse {
  final String token;
  final int userId;
  final String username;
  final String? email;
  final String? role;
  final int totalScore;

  const AuthResponse({
    required this.token,
    required this.userId,
    required this.username,
    this.email,
    this.role,
    required this.totalScore,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String? ?? '',
      userId: json['userId'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      email: json['email'] as String?,
      role: json['role'] as String?,
      totalScore: json['totalScore'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'userId': userId,
      'username': username,
      'email': email,
      'role': role,
      'totalScore': totalScore,
    };
  }

  @override
  String toString() => 'AuthResponse(userId: $userId, username: $username)';
}

class RegisterRequest {
  final String username;
  final String password;
  final String? email;

  const RegisterRequest({
    required this.username,
    required this.password,
    this.email,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'username': username,
      'password': password,
    };
    if (email != null) map['email'] = email;
    return map;
  }

  @override
  String toString() => 'RegisterRequest(username: $username)';
}