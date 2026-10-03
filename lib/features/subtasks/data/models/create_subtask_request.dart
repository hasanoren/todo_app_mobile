class CreateSubtaskRequest {
  final String title;

  const CreateSubtaskRequest({required this.title});

  Map<String, dynamic> toJson() => {'title': title.trim()};
}
