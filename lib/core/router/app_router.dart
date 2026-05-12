import 'package:ai_chat_mobile/features/auth/domain/auth_state.dart';
import 'package:ai_chat_mobile/features/auth/presentation/login_screen.dart';
import 'package:ai_chat_mobile/features/auth/presentation/signup_screen.dart';
import 'package:ai_chat_mobile/features/chat/presentation/chat_screen.dart';
import 'package:ai_chat_mobile/features/conversations/presentation/conversations_list_screen.dart';
import 'package:ai_chat_mobile/features/settings/presentation/settings_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

part 'app_router.g.dart';

/// App-wide [GoRouter]. The router instance is built once and shared via
/// Riverpod; auth-driven redirects are triggered by a [Listenable] that
/// fires whenever [currentUserProvider] changes — the router itself is
/// never recreated, so navigation history is preserved across sign-ins
/// and sign-outs.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final refreshListenable = _AuthRefreshNotifier(ref);
  ref.onDispose(refreshListenable.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshListenable,
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      final user = ref.read(currentUserProvider);
      final location = state.matchedLocation;
      final isAuthRoute = location == '/login' || location == '/signup';
      final isRoot = location == '/';

      if (user == null && !isAuthRoute) {
        return '/login';
      }
      // Signed-in users should never linger on `/` or on the auth screens.
      if (user != null && (isAuthRoute || isRoot)) {
        return '/conversations';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const _SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (_, _) => const SignupScreen(),
      ),
      GoRoute(
        path: '/conversations',
        builder: (_, _) => const ConversationsListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (_, state) => ChatScreen(
              conversationId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        builder: (_, _) => const SettingsScreen(),
      ),
    ],
  );
}

/// Briefly shown while the top-level redirect resolves on cold start.
/// In practice the redirect fires synchronously, so this is rarely visible.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

/// [ChangeNotifier] that ticks whenever [currentUserProvider] emits a new
/// value, prompting `GoRouter` to re-run its redirect.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen<User?>(
      currentUserProvider,
      (_, _) => notifyListeners(),
    );
  }
}
