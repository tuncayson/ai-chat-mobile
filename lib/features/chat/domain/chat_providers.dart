import 'package:ai_chat_mobile/features/chat/data/chat_repository.dart';
import 'package:ai_chat_mobile/features/chat/data/messages_repository.dart';
import 'package:ai_chat_mobile/features/chat/domain/message.dart';
import 'package:ai_chat_mobile/features/conversations/domain/conversation.dart';
import 'package:ai_chat_mobile/features/conversations/domain/conversations_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

part 'chat_providers.g.dart';

@Riverpod(keepAlive: true)
ChatRepository chatRepository(Ref ref) {
  return ChatRepository(Supabase.instance.client);
}

@Riverpod(keepAlive: true)
MessagesRepository messagesRepository(Ref ref) {
  return MessagesRepository(Supabase.instance.client);
}

/// Live messages for one conversation, oldest → newest.
@riverpod
Stream<List<Message>> messagesStream(Ref ref, String conversationId) {
  return ref.watch(messagesRepositoryProvider).watch(conversationId);
}

/// Derives the conversation header (title, updatedAt) from the existing
/// realtime list provider. The Edge Function bumps the title on the first
/// turn; that UPDATE event flows through [conversationsListProvider] and
/// shows up here automatically.
@riverpod
Conversation? conversationById(Ref ref, String id) {
  final async = ref.watch(conversationsListProvider);
  return switch (async) {
    AsyncData(:final value) =>
      value.where((c) => c.id == id).firstOrNull,
    _ => null,
  };
}

/// True while a `chat` Edge Function call is in flight for this
/// conversation. Drives both the input lock and the typing indicator.
@riverpod
class IsSending extends _$IsSending {
  @override
  bool build(String conversationId) => false;

  void start() => state = true;
  void finish() => state = false;
}

/// Optimistic copy of the user's last unsent message. Rendered at the
/// bottom of the message list until the realtime subscription delivers
/// the persisted row from the server (or until the request fails).
@riverpod
class PendingUserMessage extends _$PendingUserMessage {
  @override
  Message? build(String conversationId) => null;

  // Named after the action (not a setter) so call sites read as
  // `pendingUserMessageProvider(id).notifier.mark(...)` / `.clear()`.
  // ignore: use_setters_to_change_properties
  void mark(Message message) => state = message;
  void clear() => state = null;
}
