import 'package:flutter_test/flutter_test.dart';

import 'package:todo_app_mobile/core/errors/failure.dart';
import 'package:todo_app_mobile/features/ownership_transfer/data/models/create_transfer_request_dto.dart';
import 'package:todo_app_mobile/features/ownership_transfer/data/models/transfer_request_response_dto.dart';
import 'package:todo_app_mobile/features/ownership_transfer/data/models/transfer_requests_collection_response_dto.dart';
import 'package:todo_app_mobile/features/ownership_transfer/data/models/transfer_action_response_dto.dart';
import 'package:todo_app_mobile/features/ownership_transfer/domain/repositories/ownership_transfer_repository.dart';
import 'package:todo_app_mobile/features/ownership_transfer/presentation/cubits/pending_transfers_cubit.dart';
import 'package:todo_app_mobile/features/ownership_transfer/presentation/cubits/pending_transfers_state.dart';
import 'package:todo_app_mobile/features/ownership_transfer/presentation/cubits/transfer_request_cubit.dart';
import 'package:todo_app_mobile/features/ownership_transfer/presentation/cubits/transfer_request_state.dart';

class MockOwnershipTransferRepository implements OwnershipTransferRepository {
  List<TransferRequestResponseDto> pendingRequests = [];
  bool shouldThrow = false;
  String errorMessage = 'Sunucu hatası';
  TransferRequestResponseDto? createdRequest;
  TransferActionResponseDto? actionResponse;

  @override
  Future<TransferRequestResponseDto> createTransferRequest(
    String taskId,
    CreateTransferRequestDto request,
  ) async {
    if (shouldThrow) throw ServerFailure(message: errorMessage);
    return createdRequest ??
        TransferRequestResponseDto(
          id: 'tr-new',
          taskId: taskId,
          taskTitle: 'Yeni Görev',
          fromUserId: 'u1',
          fromUserEmail: 'u1@ex.com',
          toUserId: 'u2',
          toUserEmail: request.newOwnerEmail,
          status: 'Pending',
          createdAt: DateTime.now(),
        );
  }

  @override
  Future<List<TransferRequestResponseDto>> getPendingTransferRequests() async {
    if (shouldThrow) throw ServerFailure(message: errorMessage);
    return List.from(pendingRequests);
  }

  @override
  Future<TransferActionResponseDto> acceptTransferRequest(
    String requestId,
  ) async {
    if (shouldThrow) throw ServerFailure(message: errorMessage);
    pendingRequests.removeWhere((r) => r.id == requestId);
    return actionResponse ??
        const TransferActionResponseDto(message: 'Kabul edildi');
  }

  @override
  Future<TransferActionResponseDto> rejectTransferRequest(
    String requestId,
  ) async {
    if (shouldThrow) throw ServerFailure(message: errorMessage);
    pendingRequests.removeWhere((r) => r.id == requestId);
    return actionResponse ??
        const TransferActionResponseDto(message: 'Reddedildi');
  }

  @override
  Future<TransferActionResponseDto> cancelTransferRequest(
    String requestId,
  ) async {
    if (shouldThrow) throw ServerFailure(message: errorMessage);
    return actionResponse ??
        const TransferActionResponseDto(message: 'İptal edildi');
  }
}

void main() {
  group('OwnershipTransfer DTO Tests', () {
    test('CreateTransferRequestDto serializes to JSON correctly', () {
      final dto = CreateTransferRequestDto(newOwnerEmail: 'test@example.com');
      final json = dto.toJson();
      expect(json['newOwnerEmail'], 'test@example.com');
    });

    test('TransferRequestResponseDto parses JSON correctly', () {
      final json = {
        'id': 'tr-1',
        'taskId': 'task-1',
        'taskTitle': 'Test Task',
        'fromUserId': 'user-1',
        'fromUserEmail': 'owner@example.com',
        'toUserId': 'user-2',
        'toUserEmail': 'new@example.com',
        'status': 'Pending',
        'createdAt': '2026-03-30T10:00:00Z',
      };
      final dto = TransferRequestResponseDto.fromJson(json);
      expect(dto.id, 'tr-1');
      expect(dto.taskId, 'task-1');
      expect(dto.taskTitle, 'Test Task');
      expect(dto.fromUserEmail, 'owner@example.com');
      expect(dto.toUserEmail, 'new@example.com');
      expect(dto.isPending, true);
      expect(dto.isAccepted, false);
      expect(dto.isRejected, false);
      expect(dto.isCancelled, false);
    });

    test('TransferRequestsCollectionResponseDto parses list and map formats', () {
      final itemMap = {
        'id': 'tr-1',
        'taskId': 'task-1',
        'taskTitle': 'Test Task',
        'fromUserId': 'user-1',
        'fromUserEmail': 'owner@example.com',
        'toUserId': 'user-2',
        'toUserEmail': 'new@example.com',
        'status': 'Pending',
        'createdAt': '2026-03-30T10:00:00Z',
      };

      final fromMap = TransferRequestsCollectionResponseDto.fromJson({
        'items': [itemMap],
      });
      expect(fromMap.items.length, 1);
      expect(fromMap.items.first.id, 'tr-1');

      final fromList = TransferRequestsCollectionResponseDto.fromJson([itemMap]);
      expect(fromList.items.length, 1);
    });

    test('TransferActionResponseDto parses JSON correctly', () {
      final json = {
        'message': 'İşlem başarıyla tamamlandı.',
      };
      final dto = TransferActionResponseDto.fromJson(json);
      expect(dto.message, 'İşlem başarıyla tamamlandı.');
    });
  });

  group('PendingTransfersCubit Tests', () {
    late MockOwnershipTransferRepository mockRepo;
    late PendingTransfersCubit cubit;

    final dummyItem = TransferRequestResponseDto(
      id: 'tr-1',
      taskId: 'task-1',
      taskTitle: 'Project Setup',
      fromUserId: 'user-1',
      fromUserEmail: 'lead@example.com',
      toUserId: 'user-2',
      toUserEmail: 'dev@example.com',
      status: 'Pending',
      createdAt: DateTime.parse('2026-03-30T10:00:00Z'),
    );

    setUp(() {
      mockRepo = MockOwnershipTransferRepository();
      cubit = PendingTransfersCubit(repository: mockRepo);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state has initial status and empty items', () {
      expect(cubit.state.status, PendingTransfersStatus.initial);
      expect(cubit.state.items, isEmpty);
      expect(cubit.state.pendingCount, 0);
    });

    test('loadPendingTransfers succeeds and emits loaded state', () async {
      mockRepo.pendingRequests = [dummyItem];

      await cubit.loadPendingTransfers();

      expect(cubit.state.status, PendingTransfersStatus.success);
      expect(cubit.state.items.length, 1);
      expect(cubit.state.pendingCount, 1);
    });

    test('loadPendingTransfers fails and emits error state', () async {
      mockRepo.shouldThrow = true;
      mockRepo.errorMessage = 'Sunucu bağlantı hatası';

      await cubit.loadPendingTransfers();

      expect(cubit.state.status, PendingTransfersStatus.error);
      expect(cubit.state.errorMessage, 'Sunucu bağlantı hatası');
    });

    test('acceptTransfer removes item and sets success message', () async {
      mockRepo.pendingRequests = [dummyItem];
      await cubit.loadPendingTransfers();
      expect(cubit.state.items.length, 1);

      final result = await cubit.acceptTransfer('tr-1');

      expect(result, true);
      expect(cubit.state.items, isEmpty);
      expect(cubit.state.pendingCount, 0);
      expect(cubit.state.successMessage, 'Kabul edildi');
    });

    test('rejectTransfer removes item and sets success message', () async {
      mockRepo.pendingRequests = [dummyItem];
      await cubit.loadPendingTransfers();
      expect(cubit.state.items.length, 1);

      final result = await cubit.rejectTransfer('tr-1');

      expect(result, true);
      expect(cubit.state.items, isEmpty);
      expect(cubit.state.pendingCount, 0);
      expect(cubit.state.successMessage, 'Reddedildi');
    });
  });

  group('TransferRequestCubit Tests', () {
    late MockOwnershipTransferRepository mockRepo;
    late TransferRequestCubit cubit;

    setUp(() {
      mockRepo = MockOwnershipTransferRepository();
      cubit = TransferRequestCubit(repository: mockRepo);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state has initial status', () {
      expect(cubit.state.status, TransferRequestStatus.initial);
    });

    test('initiateTransfer fails if email is empty', () async {
      final result = await cubit.initiateTransfer('task-1', '   ');
      expect(result, false);
      expect(cubit.state.errorMessage, isNotNull);
    });

    test('initiateTransfer succeeds with valid email', () async {
      final result = await cubit.initiateTransfer('task-1', 'new@example.com');
      expect(result, true);
      expect(cubit.state.status, TransferRequestStatus.success);
      expect(cubit.state.createdRequest, isNotNull);
    });

    test('cancelTransfer succeeds and updates state', () async {
      final result = await cubit.cancelTransfer('tr-1');
      expect(result, true);
      expect(cubit.state.status, TransferRequestStatus.success);
      expect(cubit.state.successMessage, 'İptal edildi');
    });
  });
}

