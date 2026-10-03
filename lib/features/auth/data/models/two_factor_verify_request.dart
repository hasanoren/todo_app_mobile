class TwoFactorVerifyRequest {
  final String code;

  const TwoFactorVerifyRequest({required this.code});

  Map<String, dynamic> toJson() => {'code': code};
}
