class CreateTodoListRequest {
  final String name;
  final String? colorCode;

  const CreateTodoListRequest({
    required this.name,
    this.colorCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (colorCode != null && colorCode!.isNotEmpty) 'colorCode': colorCode,
    };
  }
}
