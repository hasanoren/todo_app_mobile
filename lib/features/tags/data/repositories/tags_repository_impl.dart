import '../../../../core/errors/api_exception.dart';
import '../../../../core/errors/failure.dart';
import 'package:todo_app_mobile/features/tasks/data/models/paginated_todo_items_response_dto.dart';
import '../../domain/repositories/tags_repository.dart';
import '../datasources/tags_remote_data_source.dart';
import '../models/create_tag_request.dart';
import '../models/tag_response_dto.dart';

class TagsRepositoryImpl implements TagsRepository {
  final TagsRemoteDataSource remoteDataSource;

  TagsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<TagResponseDto>> getSystemTags() async {
    try {
      return await remoteDataSource.getSystemTags();
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (_) {
      throw const NetworkFailure(
        message: 'Etiketler yüklenirken bir hata oluştu.',
      );
    }
  }

  @override
  Future<TagResponseDto> createTag(String name) async {
    try {
      final request = CreateTagRequest(name: name);
      return await remoteDataSource.createTag(request);
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (_) {
      throw const NetworkFailure(
        message: 'Etiket oluşturulurken bir hata oluştu.',
      );
    }
  }

  @override
  Future<PaginatedTodoItemsResponseDto> getTasksByTag(
    String tagId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      return await remoteDataSource.getTasksByTag(
        tagId,
        page: page,
        pageSize: pageSize,
      );
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (_) {
      throw const NetworkFailure(
        message: 'Etikete ait görevler yüklenirken bir hata oluştu.',
      );
    }
  }

  @override
  Future<List<TagResponseDto>> getTaskTags(String taskId) async {
    try {
      return await remoteDataSource.getTaskTags(taskId);
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (_) {
      throw const NetworkFailure(
        message: 'Görevin etiketleri yüklenirken bir hata oluştu.',
      );
    }
  }

  @override
  Future<void> attachTagToTask(String taskId, String tagId) async {
    try {
      await remoteDataSource.attachTagToTask(taskId, tagId);
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (_) {
      throw const NetworkFailure(
        message: 'Etiket göreve eklenemedi.',
      );
    }
  }

  @override
  Future<void> detachTagFromTask(String taskId, String tagId) async {
    try {
      await remoteDataSource.detachTagFromTask(taskId, tagId);
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (_) {
      throw const NetworkFailure(
        message: 'Etiket görevden kaldırılamadı.',
      );
    }
  }
}
