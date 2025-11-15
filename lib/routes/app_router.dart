import 'package:go_router/go_router.dart';
import 'package:xiaozhi/pages/auth_page.dart';
import 'package:xiaozhi/pages/chat_page.dart';
import 'package:xiaozhi/pages/home/home_page.dart';
import 'package:xiaozhi/routes/route_config.dart';

/// Shared GoRouter instance for MaterialApp.router.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutePaths.home,
  routes: <RouteBase>[
    GoRoute(
      name: AppRouteNames.home,
      path: AppRoutePaths.home,
      builder: (context, state) => const HomePageWithTabs(),
      routes: <RouteBase>[
        GoRoute(
          name: AppRouteNames.chatDetail,
          path: 'chat/:conversationId',
          builder: (context, state) {
            final conversationId = state.pathParameters['conversationId'];
            if (conversationId == null || conversationId.isEmpty) {
              return ChatPage();
            }
            return ChatPage(conversationId: conversationId);
          },
        ),
      ],
    ),
    GoRoute(
      name: AppRouteNames.chatStandalone,
      path: AppRoutePaths.chatStandalone,
      builder: (context, state) => ChatPage(),
    ),
    GoRoute(
      path: AppRoutePaths.auth,
      redirect: (context, state) => state.matchedLocation == AppRoutePaths.auth
          ? '${AppRoutePaths.auth}/login'
          : null,
      routes: <RouteBase>[
        GoRoute(
          name: AppRouteNames.authLogin,
          path: 'login',
          builder: (context, state) => const AuthLoginPage(),
        ),
        GoRoute(
          name: AppRouteNames.authRegister,
          path: 'register',
          builder: (context, state) => const AuthRegisterPage(),
        ),
      ],
    ),
  ],
);
