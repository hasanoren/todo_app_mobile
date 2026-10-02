class Login2FaRequest {
  final String twoFactorToken;
  final String code;

  Login2FaRequest({required this.twoFactorToken, required this.code});

  Map<String, dynamic> toJson() {
    return {'twoFactorToken': twoFactorToken, 'code': code};
  }
}
