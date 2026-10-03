class UpdateTodoItemRequest {
  final String title;
  final String? description;
  final DateTime? dueDate;
  final int priority;
  final String? todoListId;

  const UpdateTodoItemRequest({
    required this.title,
    this.description,
    this.dueDate,
    required this.priority,
    this.todoListId,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title.trim(),
      'priority': priority,
    };
    if (description != null) {
      map['description'] = description!.trim();
    }
    if (dueDate != null) {
      map['dueDate'] = dueDate!.toUtc().toIso8601String();
    } else {
      map['dueDate'] = null;
    }
    map['todoListId'] = todoListId;
    return map;
  }
}
