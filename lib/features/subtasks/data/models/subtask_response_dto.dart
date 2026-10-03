import 'package:equatable/equatable.dart';

class SubtaskResponseDto extends Equatable {
  final String id;
  final String taskId;
  final String title;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SubtaskResponseDto({
    required this.id,
    required this.taskId,
    required this.title,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isCompleted =>
      status.trim().toLowerCase() == 'completed' || status == '1';

  factory SubtaskResponseDto.fromJson(Map<String, dynamic> json) {
    return SubtaskResponseDto(
      id: json['id'] as String? ?? '',
      taskId: json['taskId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      status: json['status']?.toString() ?? 'Open',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())?.toLocal() ??
              DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())?.toLocal()
          : null,
    );
  }

  SubtaskResponseDto copyWith({
    String? id,
    String? taskId,
    String? title,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubtaskResponseDto(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, taskId, title, status, createdAt, updatedAt];
}

