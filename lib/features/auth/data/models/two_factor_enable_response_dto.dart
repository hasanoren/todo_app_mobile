class TwoFactorEnableResponseDto {
  final String secret;
  final String qrCodeUri;

  const TwoFactorEnableResponseDto({
    required this.secret,
    required this.qrCodeUri,
  });

  factory TwoFactorEnableResponseDto.fromJson(Map<String, dynamic> json) {
    return TwoFactorEnableResponseDto(
      secret: json['secret'] as String? ?? '',
      qrCodeUri: json['qrCodeUri'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'secret': secret,
        'qrCodeUri': qrCodeUri,
      };
}
