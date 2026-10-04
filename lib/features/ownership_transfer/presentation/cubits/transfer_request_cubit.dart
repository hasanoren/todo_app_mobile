import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../data/models/create_transfer_request_dto.dart';
import '../../domain/repositories/ownership_transfer_repository.dart';
import 'transfer_request_state.dart';

class TransferRequestCubit extends Cubit<TransferRequestState> {
  final OwnershipTransferRepository repository;

  TransferRequestCubit({required this.repository})
      : super(const TransferRequestState());

  Future<bool> initiateTransfer(String taskId, String newOwnerEmail) async {
    final trimmedEmail = newOwnerEmail.trim();
    if (trimmedEmail.isEmpty) {
      emit(
        state.copyWith(
          errorMessage: 'Lütfen devredilecek kullanıcının e-posta adresini girin.',
        ),
      );
      return false;
    }

    emit(
      state.copyWith(
        status: TransferRequestStatus.loading,
        clearMessages: true,
      ),
    );

    try {
      final request = await repository.createTransferRequest(
        taskId,
        CreateTransferRequestDto(newOwnerEmail: trimmedEmail),
      );
      emit(
        state.copyWith(
          status: TransferRequestStatus.success,
          createdRequest: request,
          successMessage: 'Devir isteği başarıyla oluşturuldu.',
        ),
      );
      return true;
    } on Failure catch (f) {
      emit(
        state.copyWith(
          status: TransferRequestStatus.error,
          errorMessage: f.message,
        ),
      );
      return false;
    } catch (_) {
      emit(
        state.copyWith(
          status: TransferRequestStatus.error,
          errorMessage: 'Devir isteği oluşturulamadı.',
        ),
      );
      return false;
    }
  }

  Future<bool> cancelTransfer(String requestId) async {
    emit(
      state.copyWith(
        status: TransferRequestStatus.loading,
        clearMessages: true,
      ),
    );

    try {
      final response = await repository.cancelTransferRequest(requestId);
      emit(
        state.copyWith(
          status: TransferRequestStatus.success,
          successMessage: response.message,
        ),
      );
      return true;
    } on Failure catch (f) {
      emit(
        state.copyWith(
          status: TransferRequestStatus.error,
          errorMessage: f.message,
        ),
      );
      return false;
    } catch (_) {
      emit(
        state.copyWith(
          status: TransferRequestStatus.error,
          errorMessage: 'Devir isteği iptal edilemedi.',
        ),
      );
      return false;
    }
  }
}

