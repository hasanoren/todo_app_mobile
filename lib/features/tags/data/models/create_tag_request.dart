class CreateTagRequest {
  final String name;

  const CreateTagRequest({required this.name});

  Map<String, dynamic> toJson() => {'name': name.trim()};
}
