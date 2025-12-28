import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/route_constants.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/chat/presentation/pages/chat_room_page.dart';
import '../../features/chat/presentation/pages/new_conversation_page.dart';
import '../../features/navigation/presentation/pages/main_navigation_page.dart';
import '../../features/post/presentation/pages/create_post_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

/// App router configuration
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: RouteConstants.login,
    debugLogDiagnostics: true,
    routes: [
      // Auth routes
      GoRoute(
        path: RouteConstants.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteConstants.register,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      // Main navigation (home)
      GoRoute(
        path: RouteConstants.home,
        name: 'home',
        builder: (context, state) => const MainNavigationPage(),
      ),
      // Create post
      GoRoute(
        path: RouteConstants.createPost,
        name: 'createPost',
        builder: (context, state) => const CreatePostPage(),
      ),
      // New conversation
      GoRoute(
        path: RouteConstants.newConversation,
        name: 'newConversation',
        builder: (context, state) => const NewConversationPage(),
      ),
      // Chat room
      GoRoute(
        path: RouteConstants.chatRoom,
        name: 'chatRoom',
        builder: (context, state) {
          final conversationId = state.pathParameters['id']!;
          return ChatRoomPage(conversationId: conversationId);
        },
      ),
      // User profile
      GoRoute(
        path: RouteConstants.userProfile,
        name: 'userProfile',
        builder: (context, state) {
          final userId = state.pathParameters['id'];
          return ProfilePage(userId: userId);
        },
      ),
      // Settings
      GoRoute(
        path: RouteConstants.settings,
        name: 'settings',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Settings - Coming Soon')),
        ),
      ),
      // Edit profile
      GoRoute(
        path: RouteConstants.editProfile,
        name: 'editProfile',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Edit Profile - Coming Soon')),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            Text('Page not found: ${state.uri}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(RouteConstants.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
