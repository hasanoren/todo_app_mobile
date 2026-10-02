class ApiException implements Exception {
  final int statusCode;
  final String title;
  final String detail;
  final Map<String, List<String>> errors;

  ApiException({
    required this.statusCode,
    required this.title,
    required this.detail,
    this.errors = const {},
  });

  factory ApiException.fromJson(Map<String, dynamic> json, int statusCode) {
    Map<String, List<String>> parsedErrors = {};
    if (json['errors'] != null && json['errors'] is Map) {
      final Map<String, dynamic> rawErrors = json['errors'];
      rawErrors.forEach((key, value) {
        if (value is List) {
          parsedErrors[key] = value.map((e) => e.toString()).toList();
        }
      });
    }

    return ApiException(
      statusCode: json['status'] ?? statusCode,
      title: json['title'] ?? 'API Error',
      detail: json['detail'] ?? 'An unexpected error occurred.',
      errors: parsedErrors,
    );
  }

  @override
  String toString() {
    return 'ApiException(statusCode: $statusCode, title: $title, detail: $detail, errors: $errors)';
  }
}
