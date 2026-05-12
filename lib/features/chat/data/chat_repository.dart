import 'dart:async';
import 'dart:io';

import 'package:ai_chat_mobile/features/chat/domain/message.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@immutable
class ChatException implements Exception {
  const ChatException(this.message);

  final String message;

  @override
  String toString() => 'ChatException: $message';
}

/// Wraps the `chat` Edge Function call. The function is responsible for
/// inserting both the user's message and the assistant's reply into the
/// `messages` table — this repository does not write to the DB. The
/// realtime subscription in `MessagesRepository.watch` surfaces those
/// rows in the UI.
class ChatRepository {
  ChatRepository(this._client);

  final SupabaseClient _client;

  Future<Message> sendMessage({
    required String conversationId,
    required String userMessage,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'chat',
        body: <String, dynamic>{
          'conversation_id': conversationId,
          'user_message': userMessage,
        },
      );

      final data = response.data;
      if (data is! Map) {
        throw const ChatException('Unexpected response from server.');
      }
      final assistantRaw = data['assistant_message'];
      if (assistantRaw is! Map) {
        throw const ChatException('Server did not return an assistant reply.');
      }
      return Message(
        id: assistantRaw['id'] as String,
        conversationId: conversationId,
        role: MessageRole.assistant,
        content: assistantRaw['content'] as String,
        createdAt: DateTime.parse(assistantRaw['created_at'] as String),
      );
    } on FunctionException catch (err) {
      throw ChatException(_messageFor(err));
    } on SocketException {
      throw const ChatException(
        'Network error. Check your connection and try again.',
      );
    } on TimeoutException {
      throw const ChatException('The request timed out. Please try again.');
    } on ChatException {
      rethrow;
    } on Object catch (err) {
      throw ChatException('Failed to send message. ($err)');
    }
  }

  String _messageFor(FunctionException err) {
    switch (err.status) {
      case 400:
        return 'Your message could not be processed. Please try again.';
      case 401:
        return 'Your session has expired. Please sign in again.';
      case 404:
        return 'Conversation not found.';
      case 502:
        return 'The AI service is temporarily unavailable. Please try again.';
    }
    return 'Failed to send message.';
  }
}
