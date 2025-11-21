import 'package:flutter/foundation.dart';
import 'package:game_center/models/user_model.dart';

@immutable
class FriendRequest {
  final int id;
  final int senderId;
  final int receiverId;
  final String status;
  final DateTime createdAt;
  final User? sender;
  final User? receiver;

  const FriendRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
    this.sender,
    this.receiver,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['id'] as int? ?? 0,
      senderId: json['senderId'] as int? ?? 0,
      receiverId: json['receiverId'] as int? ?? 0,
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      sender: json['sender'] != null ? User.fromJson(json['sender']) : null,
      receiver: json['receiver'] != null ? User.fromJson(json['receiver']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'sender': sender?.toJson(),
      'receiver': receiver?.toJson(),
    };
  }

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';

  FriendRequest copyWith({
    int? id,
    int? senderId,
    int? receiverId,
    String? status,
    DateTime? createdAt,
    User? sender,
    User? receiver,
  }) {
    return FriendRequest(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver,
    );
  }

  @override
  String toString() {
    return 'FriendRequest(id: $id, senderId: $senderId, receiverId: $receiverId, status: $status)';
  }
}

@immutable
class Friendship {
  final int id;
  final int userId;
  final int friendId;
  final User friend;
  final DateTime createdAt;

  const Friendship({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.friend,
    required this.createdAt,
  });

  factory Friendship.fromJson(Map<String, dynamic> json) {
    return Friendship(
      id: json['id'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      friendId: json['friendId'] as int? ?? 0,
      friend: User.fromJson(json['friend'] ?? {}),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'friendId': friendId,
      'friend': friend.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Friendship copyWith({
    int? id,
    int? userId,
    int? friendId,
    User? friend,
    DateTime? createdAt,
  }) {
    return Friendship(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      friendId: friendId ?? this.friendId,
      friend: friend ?? this.friend,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Friendship(id: $id, friendId: $friendId, friend: ${friend.username})';
  }
}

class SendFriendRequest {
  final int receiverId;

  const SendFriendRequest({required this.receiverId});

  Map<String, dynamic> toJson() {
    return {
      'receiverId': receiverId,
    };
  }

  @override
  String toString() => 'SendFriendRequest(receiverId: $receiverId)';
}