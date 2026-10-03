class TwoFactorDisableRequest {
  final String code;

  const TwoFactorDisableRequest({required this.code});

  Map<String, dynamic> toJson() => {'code': code};
}

