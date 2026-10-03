import 'todo_list_response_dto.dart';

class TodoListsCollectionResponseDto {
  final List<TodoListResponseDto> items;

  const TodoListsCollectionResponseDto({required this.items});

  factory TodoListsCollectionResponseDto.fromJson(dynamic json) {
    if (json is List) {
      return TodoListsCollectionResponseDto(
        items: json
            .map((item) =>
                TodoListResponseDto.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } else if (json is Map<String, dynamic>) {
      final rawItems = json['items'];
      if (rawItems is List) {
        return TodoListsCollectionResponseDto(
          items: rawItems
              .map((item) =>
                  TodoListResponseDto.fromJson(item as Map<String, dynamic>))
              .toList(),
        );
      }
    }
    return const TodoListsCollectionResponseDto(items: []);
  }
}
