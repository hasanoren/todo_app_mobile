import 'tag_response_dto.dart';

class TagsCollectionResponseDto {
  final List<TagResponseDto> items;

  const TagsCollectionResponseDto({required this.items});

  factory TagsCollectionResponseDto.fromJson(dynamic json) {
    if (json is List) {
      return TagsCollectionResponseDto(
        items: json
            .map((e) => TagResponseDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    if (json is Map<String, dynamic>) {
      final raw = json['items'] as List<dynamic>? ?? [];
      return TagsCollectionResponseDto(
        items: raw
            .map((e) => TagResponseDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    return const TagsCollectionResponseDto(items: []);
  }
}
