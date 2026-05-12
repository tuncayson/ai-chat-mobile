import 'package:ai_chat_mobile/features/conversations/domain/conversation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Talks to `public.conversations`. All authorization is delegated to the
/// row-level security policies on the table — the client never sends
/// `user_id` filters or payload values.
class ConversationsRepository {
  ConversationsRepository(this._client);

  final SupabaseClient _client;

  static const _table = 'conversations';

  /// One-shot fetch, newest first. Useful for tests and pull-to-refresh.
  Future<List<Conversation>> list() async {
    final rows = await _client
        .from(_table)
        .select()
        .order('updated_at', ascending: false);
    return rows.map(Conversation.fromJson).toList();
  }

  /// Inserts a new conversation. `user_id` is populated by the DB default
  /// (`auth.uid()`) and `title` falls back to the column default
  /// (`'New conversation'`) when not provided.
  Future<Conversation> create({String? title}) async {
    final row = await _client
        .from(_table)
        .insert(<String, dynamic>{'title': ?title})
        .select()
        .single();
    return Conversation.fromJson(row);
  }

  Future<void> delete(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }

  /// Realtime stream of the caller's conversations, newest first. RLS scopes
  /// the rows to `auth.uid() = user_id`, so no client-side filter is needed.
  Stream<List<Conversation>> watch() {
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .order('updated_at', ascending: false)
        .map((rows) => rows.map(Conversation.fromJson).toList());
  }
}
