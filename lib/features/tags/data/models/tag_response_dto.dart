import 'package:equatable/equatable.dart';

class TagResponseDto extends Equatable {
  final String id;
  final String name;
  final DateTime createdAt;

  const TagResponseDto({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory TagResponseDto.fromJson(Map<String, dynamic> json) {
    return TagResponseDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())?.toLocal() ??
                DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [id, name, createdAt];
}
