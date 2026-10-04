class CreateTransferRequestDto {
  final String newOwnerEmail;

  const CreateTransferRequestDto({required this.newOwnerEmail});

  Map<String, dynamic> toJson() => {
        'newOwnerEmail': newOwnerEmail.trim().toLowerCase(),
      };
}

