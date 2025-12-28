/// Route path constants
class RouteConstants {
  RouteConstants._();

  // Auth routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';

  // Main routes
  static const String home = '/home';
  static const String feeds = '/feeds';
  static const String search = '/search';
  static const String createPost = '/create-post';
  static const String notifications = '/notifications';
  static const String profile = '/profile';

  // Detail routes
  static const String postDetail = '/post/:id';
  static const String userProfile = '/user/:id';

  // Chat routes
  static const String conversations = '/chat';
  static const String chatRoom = '/chat/:id';
  static const String newConversation = '/chat/new';

  // Settings
  static const String settings = '/settings';
  static const String editProfile = '/edit-profile';
}
