import 'package:equatable/equatable.dart';

class TodoItemFilterDto extends Equatable {
  final int filterType;
  final String? search;
  final int? status;
  final int? priority;
  final String? todoListId;
  final DateTime? dueDateFrom;
  final DateTime? dueDateTo;
  final String sortBy;
  final String sortOrder;
  final int page;
  final int pageSize;

  const TodoItemFilterDto({
    this.filterType = 0,
    this.search,
    this.status,
    this.priority,
    this.todoListId,
    this.dueDateFrom,
    this.dueDateTo,
    this.sortBy = 'createdAt',
    this.sortOrder = 'desc',
    this.page = 1,
    this.pageSize = 20,
  });

  Map<String, dynamic> toQueryParams() {
    final query = <String, dynamic>{
      'filterType': filterType,
      'sortBy': sortBy,
      'sortOrder': sortOrder,
      'page': page,
      'pageSize': pageSize,
    };

    if (search != null && search!.trim().isNotEmpty) {
      query['search'] = search!.trim();
    }
    if (status != null) {
      query['status'] = status;
    }
    if (priority != null) {
      query['priority'] = priority;
    }
    if (todoListId != null && todoListId!.isNotEmpty) {
      query['todoListId'] = todoListId;
    }
    if (dueDateFrom != null) {
      query['dueDateFrom'] = dueDateFrom!.toUtc().toIso8601String();
    }
    if (dueDateTo != null) {
      query['dueDateTo'] = dueDateTo!.toUtc().toIso8601String();
    }

    return query;
  }

  TodoItemFilterDto copyWith({
    int? filterType,
    String? search,
    bool clearSearch = false,
    int? status,
    bool clearStatus = false,
    int? priority,
    bool clearPriority = false,
    String? todoListId,
    bool clearTodoListId = false,
    DateTime? dueDateFrom,
    bool clearDueDateFrom = false,
    DateTime? dueDateTo,
    bool clearDueDateTo = false,
    String? sortBy,
    String? sortOrder,
    int? page,
    int? pageSize,
  }) {
    return TodoItemFilterDto(
      filterType: filterType ?? this.filterType,
      search: clearSearch ? null : (search ?? this.search),
      status: clearStatus ? null : (status ?? this.status),
      priority: clearPriority ? null : (priority ?? this.priority),
      todoListId:
          clearTodoListId ? null : (todoListId ?? this.todoListId),
      dueDateFrom:
          clearDueDateFrom ? null : (dueDateFrom ?? this.dueDateFrom),
      dueDateTo: clearDueDateTo ? null : (dueDateTo ?? this.dueDateTo),
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  List<Object?> get props => [
        filterType,
        search,
        status,
        priority,
        todoListId,
        dueDateFrom,
        dueDateTo,
        sortBy,
        sortOrder,
        page,
        pageSize,
      ];
}

