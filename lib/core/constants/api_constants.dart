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
  static const String enable2fa = '/api/Auth/2fa/enable';
  static const String verify2fa = '/api/Auth/2fa/verify';
  static const String disable2fa = '/api/Auth/2fa/disable';
  static const String changePassword = '/api/Auth/change-password';

  // User Endpoints
  static const String userMe = '/api/Users/me';

  // Todo Lists Endpoints
  static const String todoLists = '/api/TodoLists';

  // Todo Items Endpoints
  static const String todoItems = '/api/TodoItems';
  static const String todoItemsTrash = '/api/TodoItems/trash';
  static String todoItemRestore(String id) => '/api/TodoItems/$id/restore';
  static String todoItemPermanent(String id) => '/api/TodoItems/$id/permanent';

  // Subtasks Endpoints
  static String taskSubtasks(String taskId) =>
      '/api/todoitems/$taskId/subtasks';
  static String subtaskComplete(String subtaskId) =>
      '/api/subtasks/$subtaskId/complete';
  static String subtask(String subtaskId) => '/api/subtasks/$subtaskId';

  // Tags Endpoints
  static const String tags = '/api/tags';
  static String tagTasks(String tagId) => '/api/tags/$tagId/todoitems';
  static String taskTags(String taskId) => '/api/todoitems/$taskId/tags';
  static String taskTag(String taskId, String tagId) =>
      '/api/todoitems/$taskId/tags/$tagId';

  // Task Shares Endpoints
  static String taskShares(String taskId) => '/api/todoitems/$taskId/shares';
  static String taskShareUser(String taskId, String userId) =>
      '/api/todoitems/$taskId/shares/$userId';
  static String taskShareMe(String taskId) =>
      '/api/todoitems/$taskId/shares/me';

  // Ownership Transfer Endpoints
  static String taskTransferRequests(String taskId) =>
      '/api/todoitems/$taskId/transfer-requests';
  static const String transferRequestsPending =
      '/api/transfer-requests/pending';
  static String transferRequestAccept(String requestId) =>
      '/api/transfer-requests/$requestId/accept';
  static String transferRequestReject(String requestId) =>
      '/api/transfer-requests/$requestId/reject';
  static String transferRequestCancel(String requestId) =>
      '/api/transfer-requests/$requestId/cancel';

  // Task Activities Endpoints
  static String taskActivities(String taskId) =>
      '/api/TodoItems/$taskId/activities';

  static const int connectTimeout = 10000;
  static const int receiveTimeout = 10000;
}
