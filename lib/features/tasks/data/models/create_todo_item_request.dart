class CreateTodoItemRequest {
  final String title;
  final String? description;
  final DateTime? dueDate;
  final int priority;
  final String? todoListId;

  const CreateTodoItemRequest({
    required this.title,
    this.description,
    this.dueDate,
    this.priority = 1,
    this.todoListId,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title.trim(),
      'priority': priority,
    };
    if (description != null && description!.trim().isNotEmpty) {
      map['description'] = description!.trim();
    }
    if (dueDate != null) {
      map['dueDate'] = dueDate!.toUtc().toIso8601String();
    }
    if (todoListId != null && todoListId!.isNotEmpty) {
      map['todoListId'] = todoListId;
    }
    return map;
  }
}
