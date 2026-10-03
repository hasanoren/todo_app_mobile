import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../data/models/tag_response_dto.dart';
import '../../domain/repositories/tags_repository.dart';
import 'task_tags_state.dart';

class TaskTagsCubit extends Cubit<TaskTagsState> {
  final TagsRepository tagsRepository;
  final String taskId;

  TaskTagsCubit({
    required this.tagsRepository,
    required this.taskId,
    List<TagResponseDto>? initialTags,
  }) : super(
         initialTags != null
             ? TaskTagsLoaded(tags: initialTags)
             : const TaskTagsInitial(),
       );

  Future<void> loadTags() async {
    emit(const TaskTagsLoading());
    try {
      final tags = await tagsRepository.getTaskTags(taskId);
      emit(TaskTagsLoaded(tags: tags));
    } on Failure catch (e) {
      emit(TaskTagsFailure(e.message));
    } catch (_) {
      emit(const TaskTagsFailure('Etiketler yüklenirken bir sorun oluştu.'));
    }
  }

  Future<bool> attachTag(TagResponseDto tag) async {
    final currentState = state;
    if (currentState is! TaskTagsLoaded) return false;

    // Idempotent check
    if (currentState.tags.any((t) => t.id == tag.id)) {
      return true;
    }

    emit(currentState.copyWith(isAttaching: true, clearErrorMessage: true));
    try {
      await tagsRepository.attachTagToTask(taskId, tag.id);
      final updatedTags = List<TagResponseDto>.from(currentState.tags)
        ..add(tag);
      emit(currentState.copyWith(tags: updatedTags, isAttaching: false));
      return true;
    } on Failure catch (e) {
      emit(currentState.copyWith(isAttaching: false, errorMessage: e.message));
      return false;
    } catch (_) {
      emit(
        currentState.copyWith(
          isAttaching: false,
          errorMessage: 'Etiket göreve eklenemedi.',
        ),
      );
      return false;
    }
  }

  Future<bool> detachTag(String tagId) async {
    final currentState = state;
    if (currentState is! TaskTagsLoaded) return false;

    emit(currentState.copyWith(detachingTagId: tagId, clearErrorMessage: true));
    try {
      await tagsRepository.detachTagFromTask(taskId, tagId);
      final updatedTags = currentState.tags
          .where((t) => t.id != tagId)
          .toList();
      emit(currentState.copyWith(tags: updatedTags, clearDetachingTagId: true));
      return true;
    } on Failure catch (e) {
      emit(
        currentState.copyWith(
          clearDetachingTagId: true,
          errorMessage: e.message,
        ),
      );
      return false;
    } catch (_) {
      emit(
        currentState.copyWith(
          clearDetachingTagId: true,
          errorMessage: 'Etiket görevden kaldırılamadı.',
        ),
      );
      return false;
    }
  }
}
