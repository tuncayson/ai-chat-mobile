import 'dart:async';

import 'package:ai_chat_mobile/features/chat/data/chat_repository.dart';
import 'package:ai_chat_mobile/features/chat/domain/chat_providers.dart';
import 'package:ai_chat_mobile/features/chat/domain/message.dart';
import 'package:ai_chat_mobile/features/chat/presentation/widgets/chat_input.dart';
import 'package:ai_chat_mobile/features/chat/presentation/widgets/message_bubble.dart';
import 'package:ai_chat_mobile/features/chat/presentation/widgets/typing_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({required this.conversationId, super.key});

  final String conversationId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();
  int _lastItemCount = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    final id = widget.conversationId;
    final pending = Message(
      id: 'pending-${DateTime.now().microsecondsSinceEpoch}',
      conversationId: id,
      role: MessageRole.user,
      content: text,
      createdAt: DateTime.now().toUtc(),
    );

    ref.read(pendingUserMessageProvider(id).notifier).mark(pending);
    ref.read(isSendingProvider(id).notifier).start();

    try {
      await ref.read(chatRepositoryProvider).sendMessage(
            conversationId: id,
            userMessage: text,
          );
    } on ChatException catch (err) {
      if (!mounted) return;
      _showError(err.message, () => unawaited(_send(text)));
    } finally {
      if (mounted) {
        ref.read(isSendingProvider(id).notifier).finish();
        ref.read(pendingUserMessageProvider(id).notifier).clear();
      }
    }
  }

  void _showError(String message, VoidCallback onRetry) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Theme.of(context).colorScheme.onError,
            onPressed: onRetry,
          ),
          duration: const Duration(seconds: 6),
        ),
      );
  }

  /// Whether the optimistic pending message should still be shown — false
  /// once the realtime stream has delivered a matching user message.
  bool _shouldShowPending(Message pending, List<Message> server) {
    const dedupeWindow = Duration(seconds: 3);
    return !server.any(
      (m) =>
          m.role == MessageRole.user &&
          m.content == pending.content &&
          m.createdAt.isAfter(pending.createdAt.subtract(dedupeWindow)),
    );
  }

  void _maybeScrollToBottom(int newCount) {
    if (newCount == _lastItemCount) return;
    _lastItemCount = newCount;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      unawaited(
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.conversationId;
    final conversation = ref.watch(conversationByIdProvider(id));
    final messagesAsync = ref.watch(messagesStreamProvider(id));
    final pending = ref.watch(pendingUserMessageProvider(id));
    final isSending = ref.watch(isSendingProvider(id));

    final serverMessages = switch (messagesAsync) {
      AsyncData(:final value) => value,
      _ => const <Message>[],
    };
    final messages = (pending != null && _shouldShowPending(pending, serverMessages))
        ? [...serverMessages, pending]
        : serverMessages;

    final showTyping = isSending;
    final itemCount = messages.length + (showTyping ? 1 : 0);
    _maybeScrollToBottom(itemCount);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          conversation?.title ?? 'Chat',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Failed to load messages: $err',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
              data: (_) {
                if (itemCount == 0) {
                  return const _EmptyChatHint();
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: itemCount,
                  itemBuilder: (context, i) {
                    if (showTyping && i == messages.length) {
                      return const TypingIndicator();
                    }
                    return MessageBubble(message: messages[i]);
                  },
                );
              },
            ),
          ),
          ChatInput(
            isSending: isSending,
            onSend: (text) => unawaited(_send(text)),
          ),
        ],
      ),
    );
  }
}

class _EmptyChatHint extends StatelessWidget {
  const _EmptyChatHint();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              size: 56,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Ask anything',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try "Help me plan my week" or "Explain async/await in Dart".',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
