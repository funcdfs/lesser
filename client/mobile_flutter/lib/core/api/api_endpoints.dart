/// API 端点常量
class ApiEndpoints {
  ApiEndpoints._();

  // 认证端点
  static const String register = '/api/v1/auth/register/';
  static const String login = '/api/v1/auth/login/';
  static const String logout = '/api/v1/auth/logout/';
  static const String tokenRefresh = '/api/v1/auth/token/refresh/';
  static const String me = '/api/v1/auth/me/';

  // 用户端点
  static const String users = '/api/v1/users/';
  static String userById(String id) => '/api/v1/users/$id/';
  static String follow(String id) => '/api/v1/users/$id/follow/';
  static String unfollow(String id) => '/api/v1/users/$id/unfollow/';

  // 信息流端点
  static const String feeds = '/api/v1/feeds/';
  static String feedById(String id) => '/api/v1/feeds/$id/';

  // 帖子端点
  static const String posts = '/api/v1/posts/';
  static String postById(String id) => '/api/v1/posts/$id/';
  static String likePost(String id) => '/api/v1/posts/$id/like/';
  static String repost(String id) => '/api/v1/posts/$id/repost/';
  static String bookmark(String id) => '/api/v1/posts/$id/bookmark/';

  // 评论端点
  static String comments(String postId) => '/api/v1/posts/$postId/comments/';
  static String commentById(String postId, String commentId) =>
      '/api/v1/posts/$postId/comments/$commentId/';

  // 搜索端点
  static const String search = '/api/v1/search/';
  static const String searchPosts = '/api/v1/search/posts/';
  static const String searchUsers = '/api/v1/search/users/';

  // 通知端点
  static const String notifications = '/api/v1/notifications/';
  static String notificationById(String id) => '/api/v1/notifications/$id/';
  static const String notificationsReadAll = '/api/v1/notifications/read-all/';

  // 聊天端点（通过聊天服务）
  static const String conversations = '/api/v1/chat/conversations';
  static String conversationById(String id) => '/api/v1/chat/conversations/$id';
  static String messages(String conversationId) =>
      '/api/v1/chat/conversations/$conversationId/messages';
  static String markAsRead(String conversationId) =>
      '/api/v1/chat/conversations/$conversationId/read';
  static const String unreadCounts = '/api/v1/chat/unread-counts';
}
