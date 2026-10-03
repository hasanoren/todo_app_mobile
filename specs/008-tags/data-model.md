# Data Model: FEAT-08 — Tags & Categorization

## Entities & DTOs

### 1. `TagResponseDto`
Represents a tag in the system or on a task.

```dart
class TagResponseDto extends Equatable {
  final String id;
  final String name;
  final DateTime createdAt;

  const TagResponseDto({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory TagResponseDto.fromJson(Map<String, dynamic> json) => ...
  Map<String, dynamic> toJson() => ...
}
```

### 2. `TagsCollectionResponseDto`
Wrapper for unpaginated collections of tags (`GET /api/tags`, `GET /api/todoitems/{taskId}/tags`).

```dart
class TagsCollectionResponseDto extends Equatable {
  final List<TagResponseDto> items;

  const TagsCollectionResponseDto({required this.items});

  factory TagsCollectionResponseDto.fromJson(dynamic json) => ...
}
```

### 3. `CreateTagRequest`
Request body for Admin tag creation (`POST /api/tags`).

```dart
class CreateTagRequest {
  final String name;

  const CreateTagRequest({required this.name});

  Map<String, dynamic> toJson() => {'name': name};
}
```

