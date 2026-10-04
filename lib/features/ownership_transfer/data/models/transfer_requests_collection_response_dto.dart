import 'package:equatable/equatable.dart';
import 'transfer_request_response_dto.dart';

class TransferRequestsCollectionResponseDto extends Equatable {
  final List<TransferRequestResponseDto> items;

  const TransferRequestsCollectionResponseDto({required this.items});

  factory TransferRequestsCollectionResponseDto.fromJson(dynamic json) {
    if (json is List) {
      return TransferRequestsCollectionResponseDto(
        items: json
            .map((item) =>
                TransferRequestResponseDto.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    }
    if (json is Map<String, dynamic>) {
      final list = json['items'] as List<dynamic>? ?? [];
      return TransferRequestsCollectionResponseDto(
        items: list
            .map((item) =>
                TransferRequestResponseDto.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    }
    return const TransferRequestsCollectionResponseDto(items: []);
  }

  @override
  List<Object?> get props => [items];
}

