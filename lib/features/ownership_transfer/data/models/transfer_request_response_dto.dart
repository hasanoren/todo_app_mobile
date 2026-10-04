import 'package:equatable/equatable.dart';

class TransferRequestResponseDto extends Equatable {
  final String id;
  final String taskId;
  final String taskTitle;
  final String fromUserId;
  final String fromUserEmail;
  final String toUserId;
  final String toUserEmail;
  final String status;
  final DateTime createdAt;
  final DateTime? respondedAt;

  const TransferRequestResponseDto({
    required this.id,
    required this.taskId,
    required this.taskTitle,
    required this.fromUserId,
    required this.fromUserEmail,
    required this.toUserId,
    required this.toUserEmail,
    required this.status,
    required this.createdAt,
    this.respondedAt,
  });

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isAccepted => status.toLowerCase() == 'accepted';
  bool get isRejected => status.toLowerCase() == 'rejected';
  bool get isCancelled => status.toLowerCase() == 'cancelled';

  factory TransferRequestResponseDto.fromJson(Map<String, dynamic> json) {
    return TransferRequestResponseDto(
      id: json['id'] as String? ?? '',
      taskId: json['taskId'] as String? ?? '',
      taskTitle: json['taskTitle'] as String? ?? '',
      fromUserId: json['fromUserId'] as String? ?? '',
      fromUserEmail: json['fromUserEmail'] as String? ?? '',
      toUserId: json['toUserId'] as String? ?? '',
      toUserEmail: json['toUserEmail'] as String? ?? '',
      status: json['status'] as String? ?? 'Pending',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      respondedAt: json['respondedAt'] != null
          ? DateTime.tryParse(json['respondedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'taskTitle': taskTitle,
      'fromUserId': fromUserId,
      'fromUserEmail': fromUserEmail,
      'toUserId': toUserId,
      'toUserEmail': toUserEmail,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        taskId,
        taskTitle,
        fromUserId,
        fromUserEmail,
        toUserId,
        toUserEmail,
        status,
        createdAt,
        respondedAt,
      ];
}

