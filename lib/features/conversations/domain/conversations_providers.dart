import 'package:ai_chat_mobile/features/auth/domain/auth_state.dart';
import 'package:ai_chat_mobile/features/conversations/data/conversations_repository.dart';
import 'package:ai_chat_mobile/features/conversations/domain/conversation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

part 'conversations_providers.g.dart';

@Riverpod(keepAlive: true)
ConversationsRepository conversationsRepository(Ref ref) {
  return ConversationsRepository(Supabase.instance.client);
}

/// Live list of the caller's conversations. Re-subscribes whenever the
/// signed-in user changes so signing out clears the previous user's
/// stream and signing back in produces a fresh subscription.
@riverpod
Stream<List<Conversation>> conversationsList(Ref ref) {
  ref.watch(currentUserProvider);
  return ref.watch(conversationsRepositoryProvider).watch();
}
