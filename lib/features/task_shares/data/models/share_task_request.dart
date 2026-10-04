class ShareTaskRequest {
  final String email;

  const ShareTaskRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email.trim().toLowerCase()};
}

