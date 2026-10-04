import 'package:equatable/equatable.dart';

class ShareTaskResponseDto extends Equatable {
  final String message;

  const ShareTaskResponseDto({required this.message});

  factory ShareTaskResponseDto.fromJson(Map<String, dynamic> json) {
    return ShareTaskResponseDto(
      message: json['message'] as String? ?? 'Görev başarıyla paylaşıldı.',
    );
  }

  @override
  List<Object?> get props => [message];
}

