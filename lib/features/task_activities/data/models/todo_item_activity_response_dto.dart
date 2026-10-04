import 'package:equatable/equatable.dart';

class TodoItemActivityResponseDto extends Equatable {
  final String id;
  final String userId;
  final String userEmail;
  final String action;
  final String? details;
  final DateTime createdAt;

  const TodoItemActivityResponseDto({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.action,
    this.details,
    required this.createdAt,
  });

  factory TodoItemActivityResponseDto.fromJson(Map<String, dynamic> json) {
    return TodoItemActivityResponseDto(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userEmail: json['userEmail'] as String? ?? '',
      action: json['action'] as String? ?? '',
      details: json['details'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userEmail': userEmail,
      'action': action,
      'details': details,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, userId, userEmail, action, details, createdAt];
}
