import 'package:equatable/equatable.dart';

import '../../../tasks/data/models/todo_item_response_dto.dart';

class SharesCollectionResponseDto extends Equatable {
  final List<SharedUserItemDto> items;

  const SharesCollectionResponseDto({required this.items});

  factory SharesCollectionResponseDto.fromJson(dynamic json) {
    if (json is List) {
      return SharesCollectionResponseDto(
        items: json
            .map((item) =>
                SharedUserItemDto.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    }
    if (json is Map<String, dynamic>) {
      final list = json['items'] as List<dynamic>? ?? [];
      return SharesCollectionResponseDto(
        items: list
            .map((item) =>
                SharedUserItemDto.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    }
    return const SharesCollectionResponseDto(items: []);
  }

  @override
  List<Object?> get props => [items];
}

