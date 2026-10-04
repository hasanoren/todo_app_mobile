import 'package:equatable/equatable.dart';

import '../../data/models/tag_response_dto.dart';

abstract class TaskTagsState extends Equatable {
  const TaskTagsState();

  @override
  List<Object?> get props => [];
}

class TaskTagsInitial extends TaskTagsState {
  const TaskTagsInitial();
}

class TaskTagsLoading extends TaskTagsState {
  const TaskTagsLoading();
}

class TaskTagsLoaded extends TaskTagsState {
  final List<TagResponseDto> tags;
  final bool isAttaching;
  final String? detachingTagId;
  final String? errorMessage;

  const TaskTagsLoaded({
    required this.tags,
    this.isAttaching = false,
    this.detachingTagId,
    this.errorMessage,
  });

  TaskTagsLoaded copyWith({
    List<TagResponseDto>? tags,
    bool? isAttaching,
    String? detachingTagId,
    bool clearDetachingTagId = false,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return TaskTagsLoaded(
      tags: tags ?? this.tags,
      isAttaching: isAttaching ?? this.isAttaching,
      detachingTagId: clearDetachingTagId
          ? null
          : (detachingTagId ?? this.detachingTagId),
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [tags, isAttaching, detachingTagId, errorMessage];
}

class TaskTagsFailure extends TaskTagsState {
  final String message;

  const TaskTagsFailure(this.message);

  @override
  List<Object?> get props => [message];
}
