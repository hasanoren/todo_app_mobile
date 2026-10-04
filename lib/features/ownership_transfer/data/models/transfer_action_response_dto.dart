import 'package:equatable/equatable.dart';

class TransferActionResponseDto extends Equatable {
  final String message;

  const TransferActionResponseDto({required this.message});

  factory TransferActionResponseDto.fromJson(Map<String, dynamic> json) {
    return TransferActionResponseDto(
      message: json['message'] as String? ?? 'İşlem başarıyla tamamlandı.',
    );
  }

  @override
  List<Object?> get props => [message];
}

