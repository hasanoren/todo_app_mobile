# Data Models: Todo Lists (FEAT-05)

## Entities & DTOs

### 1. TodoListResponseDto
Maps to API schema `TodoListResponse`:
```dart
class TodoListResponseDto {
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

  factory TodoListResponseDto.fromJson(Map<String, dynamic> json) => ...;
  Map<String, dynamic> toJson() => ...;
}
```

### 2. CreateTodoListRequest
Payload for `POST /api/TodoLists`:
```dart
class CreateTodoListRequest {
  final String name;
  final String? colorCode;

  const CreateTodoListRequest({
    required this.name,
    this.colorCode,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    if (colorCode != null) 'colorCode': colorCode,
  };
}
```

### 3. UpdateTodoListRequest
Payload for `PUT /api/TodoLists/{id}`:
```dart
class UpdateTodoListRequest {
  final String name;
  final String? colorCode;

  const UpdateTodoListRequest({
    required this.name,
    this.colorCode,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    if (colorCode != null) 'colorCode': colorCode,
  };
}
```

### 4. TodoListsCollectionResponseDto
Maps to `CollectionResponse<TodoListResponse>`:
```dart
class TodoListsCollectionResponseDto {
  final List<TodoListResponseDto> items;

  const TodoListsCollectionResponseDto({required this.items});

  factory TodoListsCollectionResponseDto.fromJson(Map<String, dynamic> json) => ...;
}
```

---

## State Models

### 1. TodoListsState
Manages list collection state:
- `isLoading`: bool
- `lists`: List<TodoListResponseDto>
- `errorMessage`: String?
- `actionMessage`: String?

### 2. TodoListFormState
Manages creation/editing modal state:
- `name`: String
- `colorCode`: String
- `nameError`: String?
- `isSubmitting`: bool
- `isSuccess`: bool
- `errorMessage`: String?
