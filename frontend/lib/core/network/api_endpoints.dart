class ApiEndpoints {
  // Toggle this for development
  static const String baseUrl = 'http://127.0.0.1:8001/api';

  static const String health = '/health';
  static const String feeds = '/feeds/';

  // Authentication endpoints
  static const String register = '/users/register/';
  static const String login = '/users/login/';
  static const String logout = '/users/logout/';
  static const String profile = '/users/profile/';
}
