/// API endpoint constants
class ApiEndpoints {
  ApiEndpoints._();

  // Auth endpoints
  static const String register = '/api/v1/auth/register/';
  static const String login = '/api/v1/auth/login/';
  static const String logout = '/api/v1/auth/logout/';
  static const String tokenRefresh = '/api/v1/auth/token/refresh/';
  static const String me = '/api/v1/auth/me/';

  // User endpoints
  static const String users = '/api/v1/users/';
  static String userById(String id) => '/api/v1/users/$id/';
  static String follow(String id) => '/api/v1/users/$id/follow/';
  static String unfollow(String id) => '/api/v1/users/$id/unfollow/';

  // Feed endpoints
  static const String feeds = '/api/v1/feeds/';
  static String feedById(String id) => '/api/v1/feeds/$id/';

  // Post endpoints
  static const String posts = '/api/v1/posts/';
  static String postById(String id) => '/api/v1/posts/$id/';
  static String likePost(String id) => '/api/v1/posts/$id/like/';
  static String repost(String id) => '/api/v1/posts/$id/repost/';
  static String bookmark(String id) => '/api/v1/posts/$id/bookmark/';

  // Comment endpoints
  static String comments(String postId) => '/api/v1/posts/$postId/comments/';
  static String commentById(String postId, String commentId) =>
      '/api/v1/posts/$postId/comments/$commentId/';

  // Search endpoints
  static const String search = '/api/v1/search/';
  static const String searchPosts = '/api/v1/search/posts/';
  static const String searchUsers = '/api/v1/search/users/';

  // Notification endpoints
  static const String notifications = '/api/v1/notifications/';
  static String notificationById(String id) => '/api/v1/notifications/$id/';
  static const String notificationsMarkAllRead = '/api/v1/notifications/mark-all-read/';

  // Chat endpoints (via chat service)
  static const String conversations = '/api/v1/chat/conversations/';
  static String conversationById(String id) => '/api/v1/chat/conversations/$id/';
  static String messages(String conversationId) =>
      '/api/v1/chat/conversations/$conversationId/messages/';
}
