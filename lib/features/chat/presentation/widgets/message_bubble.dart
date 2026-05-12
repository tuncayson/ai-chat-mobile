import 'package:ai_chat_mobile/core/theme/app_theme.dart';
import 'package:ai_chat_mobile/features/chat/domain/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({required this.message, super.key});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.role == MessageRole.user;
    final bubbleColor = isUser
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceContainerHigh;
    final textColor = isUser
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;
    final maxWidth = MediaQuery.of(context).size.width * 0.78;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: GestureDetector(
          onLongPress: () => _showTimestamp(context),
          child: Opacity(
            opacity: message.isPending ? 0.7 : 1,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius:
                      BorderRadius.circular(AppRadii.messageBubble),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: isUser
                      ? Text(
                          message.content,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: textColor),
                        )
                      : MarkdownBody(
                          data: message.content,
                          selectable: true,
                          styleSheet:
                              MarkdownStyleSheet.fromTheme(theme).copyWith(
                            p: theme.textTheme.bodyMedium
                                ?.copyWith(color: textColor),
                            code: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                              backgroundColor: theme.colorScheme.surface,
                              color: textColor,
                            ),
                            codeblockDecoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            codeblockPadding: const EdgeInsets.all(12),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showTimestamp(BuildContext context) {
    final local = message.createdAt.toLocal();
    final label = DateFormat.yMMMd().add_jm().format(local);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(label),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
