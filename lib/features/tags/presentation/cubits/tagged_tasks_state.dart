import 'package:equatable/equatable.dart';
import 'package:todo_app_mobile/features/tasks/data/models/todo_item_response_dto.dart';

enum TaggedTasksStatus { initial, loading, success, error }

class TaggedTasksState extends Equatable {
  final TaggedTasksStatus status;
  final List<TodoItemResponseDto> items;
  final int page;
  final bool hasNextPage;
  final bool isLoadingMore;
  final String? errorMessage;
  final int totalCount;

  const TaggedTasksState({
    this.status = TaggedTasksStatus.initial,
    this.items = const [],
    this.page = 1,
    this.hasNextPage = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.totalCount = 0,
  });

  TaggedTasksState copyWith({
    TaggedTasksStatus? status,
    List<TodoItemResponseDto>? items,
    int? page,
    bool? hasNextPage,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearErrorMessage = false,
    int? totalCount,
  }) {
    return TaggedTasksState(
      status: status ?? this.status,
      items: items ?? this.items,
      page: page ?? this.page,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      totalCount: totalCount ?? this.totalCount,
    );
  }

  @override
  List<Object?> get props => [
        status,
        items,
        page,
        hasNextPage,
        isLoadingMore,
        errorMessage,
        totalCount,
      ];
}
