import 'package:flutter/foundation.dart';

enum MessageRole { user, assistant }

/// Mirrors a row from `public.messages`. The `id` of a locally-created
/// optimistic message is prefixed with `pending-` until the realtime
/// subscription delivers the real row from the DB.
@immutable
class Message {
  const Message({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      role: MessageRole.values.byName(json['role'] as String),
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  final String id;
  final String conversationId;
  final MessageRole role;
  final String content;
  final DateTime createdAt;

  bool get isPending => id.startsWith('pending-');

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'conversation_id': conversationId,
        'role': role.name,
        'content': content,
        'created_at': createdAt.toIso8601String(),
      };

  Message copyWith({
    String? id,
    String? conversationId,
    MessageRole? role,
    String? content,
    DateTime? createdAt,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message &&
        other.id == id &&
        other.conversationId == conversationId &&
        other.role == role &&
        other.content == content &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode =>
      Object.hash(id, conversationId, role, content, createdAt);
}
