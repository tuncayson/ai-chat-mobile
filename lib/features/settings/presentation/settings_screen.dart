import 'dart:async';

import 'package:ai_chat_mobile/core/config/package_info_provider.dart';
import 'package:ai_chat_mobile/core/theme/theme_mode_provider.dart';
import 'package:ai_chat_mobile/features/auth/data/auth_repository.dart';
import 'package:ai_chat_mobile/features/auth/domain/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Update this when the repo is pushed to GitHub.
const _githubRepoUrl = 'https://github.com/tuncayson/ai-chat-mobile';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeModeControllerProvider);
    final asyncPackageInfo = ref.watch(packageInfoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SectionHeader('Account'),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Email'),
            subtitle: Text(user?.email ?? '—'),
          ),
          const Divider(height: 1),
          const _SectionHeader('Appearance'),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark mode'),
            subtitle: const Text('Saved to this device.'),
            value: themeMode == ThemeMode.dark,
            onChanged: (isDark) => unawaited(
              ref
                  .read(themeModeControllerProvider.notifier)
                  .setMode(isDark ? ThemeMode.dark : ThemeMode.light),
            ),
          ),
          const Divider(height: 1),
          const _SectionHeader('About'),
          const ListTile(
            leading: Icon(Icons.auto_awesome_outlined),
            title: Text('AI Chat'),
            subtitle: Text(
              'A clean, modern chat app powered by Supabase + Claude.',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Source on GitHub'),
            subtitle: const Text(_githubRepoUrl),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => unawaited(_openGithub(context)),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Version'),
            subtitle: Text(_versionLabel(asyncPackageInfo)),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            child: FilledButton.tonalIcon(
              icon: const Icon(Icons.logout),
              label: const Text('Sign out'),
              onPressed: () => unawaited(_confirmSignOut(context, ref)),
            ),
          ),
        ],
      ),
    );
  }

  String _versionLabel(AsyncValue<PackageInfo> asyncInfo) {
    return switch (asyncInfo) {
      AsyncData(:final value) =>
        '${value.version} (build ${value.buildNumber})',
      AsyncError() => '—',
      _ => 'Loading…',
    };
  }

  Future<void> _openGithub(BuildContext context) async {
    final uri = Uri.parse(_githubRepoUrl);
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Could not open the browser.')),
        );
    }
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You can sign back in any time.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(authRepositoryProvider).signOut();
      // Router redirect listenable will pick up the auth state change
      // and send the user back to /login.
    } on AuthException catch (err) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(err.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
