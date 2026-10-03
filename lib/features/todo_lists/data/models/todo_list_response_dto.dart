import 'package:equatable/equatable.dart';

class TodoListResponseDto extends Equatable {
  final String id;
  final String name;
  final String? colorCode;
  final String ownerId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TodoListResponseDto({
    required this.id,
    required this.name,
    this.colorCode,
    required this.ownerId,
    required this.createdAt,
    this.updatedAt,
  });

  factory TodoListResponseDto.fromJson(Map<String, dynamic> json) {
    return TodoListResponseDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      colorCode: json['colorCode'] as String?,
      ownerId: json['ownerId'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'colorCode': colorCode,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  TodoListResponseDto copyWith({
    String? id,
    String? name,
    String? colorCode,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TodoListResponseDto(
      id: id ?? this.id,
      name: name ?? this.name,
      colorCode: colorCode ?? this.colorCode,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, colorCode, ownerId, createdAt, updatedAt];
}

