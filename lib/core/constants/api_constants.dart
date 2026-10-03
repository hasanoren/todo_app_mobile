class ApiConstants {
  static const String baseUrl =
      'https://todoapp-api-gudhgje6bvfqg3ev.centralus-01.azurewebsites.net';

  // Auth Endpoints
  static const String register = '/api/Auth/register';
  static const String login = '/api/Auth/login';
  static const String login2fa = '/api/Auth/login-2fa';
  static const String refresh = '/api/Auth/refresh';
  static const String logout = '/api/Auth/logout';
  static const String forgotPassword = '/api/Auth/forgot-password';
  static const String resetPassword = '/api/Auth/reset-password';

  static const int connectTimeout = 10000;
  static const int receiveTimeout = 10000;
}
