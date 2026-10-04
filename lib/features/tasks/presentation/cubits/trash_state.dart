import 'package:equatable/equatable.dart';

import '../../data/models/todo_item_response_dto.dart';

enum TrashStatus {
  initial,
  loading,
  loaded,
  actionInProgress,
  error,
}

class TrashState extends Equatable {
  final TrashStatus status;
  final List<TodoItemResponseDto> items;
  final int page;
  final int totalPages;
  final int totalCount;
  final bool hasMore;
  final bool isLoadingMore;
  final String? errorMessage;
  final String? successMessage;

  const TrashState({
    this.status = TrashStatus.initial,
    this.items = const [],
    this.page = 1,
    this.totalPages = 1,
    this.totalCount = 0,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.successMessage,
  });

  TrashState copyWith({
    TrashStatus? status,
    List<TodoItemResponseDto>? items,
    int? page,
    int? totalPages,
    int? totalCount,
    bool? hasMore,
    bool? isLoadingMore,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return TrashState(
      status: status ?? this.status,
      items: items ?? this.items,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearMessages ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        items,
        page,
        totalPages,
        totalCount,
        hasMore,
        isLoadingMore,
        errorMessage,
        successMessage,
      ];
}
