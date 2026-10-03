import 'package:equatable/equatable.dart';
import '../../domain/entities/todo_item_enums.dart';

class SubTaskItemDto extends Equatable {
  final String id;
  final String taskId;
  final String title;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SubTaskItemDto({
    required this.id,
    required this.taskId,
    required this.title,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isCompleted =>
      status.trim().toLowerCase() == 'completed' || status == '1';

  factory SubTaskItemDto.fromJson(Map<String, dynamic> json) {
    return SubTaskItemDto(
      id: json['id'] as String? ?? '',
      taskId: json['taskId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      status: json['status'] as String? ?? 'Open',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  @override
  List<Object?> get props => [id, taskId, title, status, createdAt, updatedAt];
}

class TagItemDto extends Equatable {
  final String id;
  final String name;
  final DateTime createdAt;

  const TagItemDto({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory TagItemDto.fromJson(Map<String, dynamic> json) {
    return TagItemDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, name, createdAt];
}

class SharedUserItemDto extends Equatable {
  final String userId;
  final String email;
  final DateTime sharedAt;

  const SharedUserItemDto({
    required this.userId,
    required this.email,
    required this.sharedAt,
  });

  factory SharedUserItemDto.fromJson(Map<String, dynamic> json) {
    return SharedUserItemDto(
      userId: json['userId'] as String? ?? '',
      email: json['email'] as String? ?? '',
      sharedAt: json['sharedAt'] != null
          ? DateTime.tryParse(json['sharedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [userId, email, sharedAt];
}

class TodoItemResponseDto extends Equatable {
  final String id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final String status;
  final String priority;
  final String? todoListId;
  final String ownerId;
  final bool isOwner;
  final String? completedByUserId;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;
  final DateTime? deletedAt;
  final List<SubTaskItemDto> subTasks;
  final List<TagItemDto> tags;
  final List<SharedUserItemDto> sharedWith;

  const TodoItemResponseDto({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    required this.status,
    required this.priority,
    this.todoListId,
    required this.ownerId,
    required this.isOwner,
    this.completedByUserId,
    this.completedAt,
    required this.createdAt,
    this.updatedAt,
    required this.isDeleted,
    this.deletedAt,
    this.subTasks = const [],
    this.tags = const [],
    this.sharedWith = const [],
  });

  TaskStatus get taskStatus => TaskStatus.fromServer(status);
  bool get isCompleted => taskStatus.isCompleted;
  TaskPriority get taskPriority => TaskPriority.fromServer(priority);
  bool get isOverdue =>
      dueDate != null && !isCompleted && dueDate!.isBefore(DateTime.now());

  factory TodoItemResponseDto.fromJson(Map<String, dynamic> json) {
    return TodoItemResponseDto(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'].toString())?.toLocal()
          : null,
      status: json['status']?.toString() ?? 'Open',
      priority: json['priority']?.toString() ?? 'Medium',
      todoListId: json['todoListId'] as String?,
      ownerId: json['ownerId'] as String? ?? '',
      isOwner: json['isOwner'] as bool? ?? false,
      completedByUserId: json['completedByUserId'] as String?,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'].toString())?.toLocal()
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())?.toLocal() ??
              DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())?.toLocal()
          : null,
      isDeleted: json['isDeleted'] as bool? ?? false,
      deletedAt: json['deletedAt'] != null
          ? DateTime.tryParse(json['deletedAt'].toString())?.toLocal()
          : null,
      subTasks: (json['subTasks'] as List<dynamic>?)
              ?.map((e) => SubTaskItemDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => TagItemDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      sharedWith: (json['sharedWith'] as List<dynamic>?)
              ?.map((e) => SharedUserItemDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  TodoItemResponseDto copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? status,
    String? priority,
    String? todoListId,
    String? ownerId,
    bool? isOwner,
    String? completedByUserId,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    DateTime? deletedAt,
    List<SubTaskItemDto>? subTasks,
    List<TagItemDto>? tags,
    List<SharedUserItemDto>? sharedWith,
  }) {
    return TodoItemResponseDto(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      todoListId: todoListId ?? this.todoListId,
      ownerId: ownerId ?? this.ownerId,
      isOwner: isOwner ?? this.isOwner,
      completedByUserId: completedByUserId ?? this.completedByUserId,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      subTasks: subTasks ?? this.subTasks,
      tags: tags ?? this.tags,
      sharedWith: sharedWith ?? this.sharedWith,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        dueDate,
        status,
        priority,
        todoListId,
        ownerId,
        isOwner,
        completedByUserId,
        completedAt,
        createdAt,
        updatedAt,
        isDeleted,
        deletedAt,
        subTasks,
        tags,
        sharedWith,
      ];
}
