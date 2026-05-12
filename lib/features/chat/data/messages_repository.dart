import 'package:ai_chat_mobile/features/chat/domain/message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Reads and streams rows from `public.messages`. RLS scopes everything to
/// messages whose parent conversation belongs to the authenticated caller,
/// so no client-side ownership filter is needed.
class MessagesRepository {
  MessagesRepository(this._client);

  final SupabaseClient _client;

  static const _table = 'messages';

  /// Returns all messages in a conversation, oldest first.
  Future<List<Message>> list(String conversationId) async {
    final rows = await _client
        .from(_table)
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);
    return rows.map(Message.fromJson).toList();
  }

  /// Live stream of messages in a conversation, oldest first. Emits a new
  /// list whenever a row is inserted, updated, or deleted in the table
  /// (the Edge Function inserts both the user message and the assistant
  /// reply, and both arrive here automatically).
  Stream<List<Message>> watch(String conversationId) {
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true)
        .map((rows) => rows.map(Message.fromJson).toList());
  }
}
