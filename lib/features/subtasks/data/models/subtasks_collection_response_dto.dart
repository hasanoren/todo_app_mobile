import 'subtask_response_dto.dart';

class SubtasksCollectionResponseDto {
  final List<SubtaskResponseDto> items;

  const SubtasksCollectionResponseDto({required this.items});

  factory SubtasksCollectionResponseDto.fromJson(Map<String, dynamic> json) {
    final raw = json['items'] as List<dynamic>? ?? [];
    return SubtasksCollectionResponseDto(
      items: raw
          .map((e) => SubtaskResponseDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
