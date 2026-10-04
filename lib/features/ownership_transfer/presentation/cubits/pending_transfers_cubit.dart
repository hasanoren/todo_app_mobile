import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/repositories/ownership_transfer_repository.dart';
import 'pending_transfers_state.dart';

class PendingTransfersCubit extends Cubit<PendingTransfersState> {
  final OwnershipTransferRepository repository;

  PendingTransfersCubit({required this.repository})
      : super(const PendingTransfersState());

  @override
  void emit(PendingTransfersState state) {
    if (!isClosed) {
      super.emit(state);
    }
  }

  Future<void> loadPendingTransfers() async {
    emit(
      state.copyWith(
        status: PendingTransfersStatus.loading,
        clearMessages: true,
      ),
    );

    try {
      final items = await repository.getPendingTransferRequests();
      emit(
        state.copyWith(
          status: PendingTransfersStatus.success,
          items: items,
          clearMessages: true,
        ),
      );
    } on Failure catch (f) {
      emit(
        state.copyWith(
          status: PendingTransfersStatus.error,
          errorMessage: f.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: PendingTransfersStatus.error,
          errorMessage: 'Bekleyen devir istekleri yüklenemedi.',
        ),
      );
    }
  }

  Future<bool> acceptTransfer(String requestId) async {
    emit(
      state.copyWith(
        status: PendingTransfersStatus.actionInProgress,
        clearMessages: true,
      ),
    );

    try {
      final targetItem =
          state.items.where((item) => item.id == requestId).firstOrNull;
      final response = await repository.acceptTransferRequest(requestId);
      if (targetItem != null) {
        await repository.clearActiveOutgoingTransferRequest(targetItem.taskId);
      }
      final remaining =
          state.items.where((item) => item.id != requestId).toList();
      emit(
        state.copyWith(
          status: PendingTransfersStatus.success,
          items: remaining,
          successMessage: response.message,
        ),
      );
      return true;
    } on Failure catch (f) {
      emit(
        state.copyWith(
          status: PendingTransfersStatus.success,
          errorMessage: f.message,
        ),
      );
      return false;
    } catch (_) {
      emit(
        state.copyWith(
          status: PendingTransfersStatus.success,
          errorMessage: 'Devir isteği kabul edilemedi.',
        ),
      );
      return false;
    }
  }

  Future<bool> rejectTransfer(String requestId) async {
    emit(
      state.copyWith(
        status: PendingTransfersStatus.actionInProgress,
        clearMessages: true,
      ),
    );

    try {
      final targetItem =
          state.items.where((item) => item.id == requestId).firstOrNull;
      final response = await repository.rejectTransferRequest(requestId);
      if (targetItem != null) {
        await repository.clearActiveOutgoingTransferRequest(targetItem.taskId);
      }
      final remaining =
          state.items.where((item) => item.id != requestId).toList();
      emit(
        state.copyWith(
          status: PendingTransfersStatus.success,
          items: remaining,
          successMessage: response.message,
        ),
      );
      return true;
    } on Failure catch (f) {
      emit(
        state.copyWith(
          status: PendingTransfersStatus.success,
          errorMessage: f.message,
        ),
      );
      return false;
    } catch (_) {
      emit(
        state.copyWith(
          status: PendingTransfersStatus.success,
          errorMessage: 'Devir isteği reddedilemedi.',
        ),
      );
      return false;
    }
  }
}

