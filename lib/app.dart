import 'package:ai_chat_mobile/core/router/app_router.dart';
import 'package:ai_chat_mobile/core/theme/app_theme.dart';
import 'package:ai_chat_mobile/core/theme/theme_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Root application widget. Wires the go_router config from
/// [appRouterProvider] and the user-selected theme from
/// [themeModeControllerProvider] into [MaterialApp.router].
class AiChatApp extends ConsumerWidget {
  const AiChatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeControllerProvider);
    return MaterialApp.router(
      title: 'AI Chat',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
