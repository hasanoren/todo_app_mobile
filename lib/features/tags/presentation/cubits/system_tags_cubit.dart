import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../data/models/tag_response_dto.dart';
import '../../domain/repositories/tags_repository.dart';
import 'system_tags_state.dart';

class SystemTagsCubit extends Cubit<SystemTagsState> {
  final TagsRepository tagsRepository;

  SystemTagsCubit({required this.tagsRepository})
    : super(const SystemTagsInitial());

  Future<void> loadSystemTags() async {
    emit(const SystemTagsLoading());
    try {
      final tags = await tagsRepository.getSystemTags();
      emit(SystemTagsLoaded(tags: tags));
    } on Failure catch (e) {
      emit(SystemTagsFailure(e.message));
    } catch (_) {
      emit(const SystemTagsFailure('Etiketler yüklenirken bir sorun oluştu.'));
    }
  }

  Future<TagResponseDto?> createTag(String name) async {
    final currentState = state;
    if (currentState is! SystemTagsLoaded) {
      return null;
    }

    emit(
      currentState.copyWith(
        isCreating: true,
        clearCreateError: true,
        clearNewlyCreatedTag: true,
      ),
    );

    try {
      final newTag = await tagsRepository.createTag(name);
      final updatedTags = List<TagResponseDto>.from(currentState.tags)
        ..add(newTag);
      emit(
        currentState.copyWith(
          tags: updatedTags,
          isCreating: false,
          newlyCreatedTag: newTag,
        ),
      );
      return newTag;
    } on Failure catch (e) {
      emit(currentState.copyWith(isCreating: false, createError: e.message));
      return null;
    } catch (_) {
      emit(
        currentState.copyWith(
          isCreating: false,
          createError: 'Etiket oluşturulamadı.',
        ),
      );
      return null;
    }
  }
}
