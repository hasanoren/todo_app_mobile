import 'package:equatable/equatable.dart';
import '../../data/models/tag_response_dto.dart';

abstract class SystemTagsState extends Equatable {
  const SystemTagsState();

  @override
  List<Object?> get props => [];
}

class SystemTagsInitial extends SystemTagsState {
  const SystemTagsInitial();
}

class SystemTagsLoading extends SystemTagsState {
  const SystemTagsLoading();
}

class SystemTagsLoaded extends SystemTagsState {
  final List<TagResponseDto> tags;
  final bool isCreating;
  final String? createError;
  final TagResponseDto? newlyCreatedTag;

  const SystemTagsLoaded({
    required this.tags,
    this.isCreating = false,
    this.createError,
    this.newlyCreatedTag,
  });

  SystemTagsLoaded copyWith({
    List<TagResponseDto>? tags,
    bool? isCreating,
    String? createError,
    bool clearCreateError = false,
    TagResponseDto? newlyCreatedTag,
    bool clearNewlyCreatedTag = false,
  }) {
    return SystemTagsLoaded(
      tags: tags ?? this.tags,
      isCreating: isCreating ?? this.isCreating,
      createError:
          clearCreateError ? null : (createError ?? this.createError),
      newlyCreatedTag: clearNewlyCreatedTag
          ? null
          : (newlyCreatedTag ?? this.newlyCreatedTag),
    );
  }

  @override
  List<Object?> get props => [tags, isCreating, createError, newlyCreatedTag];
}

class SystemTagsFailure extends SystemTagsState {
  final String message;

  const SystemTagsFailure(this.message);

  @override
  List<Object?> get props => [message];
}

