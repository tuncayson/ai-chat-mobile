// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(chatRepository)
final chatRepositoryProvider = ChatRepositoryProvider._();

final class ChatRepositoryProvider
    extends $FunctionalProvider<ChatRepository, ChatRepository, ChatRepository>
    with $Provider<ChatRepository> {
  ChatRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatRepositoryHash();

  @$internal
  @override
  $ProviderElement<ChatRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ChatRepository create(Ref ref) {
    return chatRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatRepository>(value),
    );
  }
}

String _$chatRepositoryHash() => r'2ef1b620f16ce043a1e5072adefc3e734a6b9bff';

@ProviderFor(messagesRepository)
final messagesRepositoryProvider = MessagesRepositoryProvider._();

final class MessagesRepositoryProvider
    extends
        $FunctionalProvider<
          MessagesRepository,
          MessagesRepository,
          MessagesRepository
        >
    with $Provider<MessagesRepository> {
  MessagesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'messagesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$messagesRepositoryHash();

  @$internal
  @override
  $ProviderElement<MessagesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MessagesRepository create(Ref ref) {
    return messagesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MessagesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MessagesRepository>(value),
    );
  }
}

String _$messagesRepositoryHash() =>
    r'f1b3125e385e0067e82c6be65b345fe6ce20e456';

/// Live messages for one conversation, oldest → newest.

@ProviderFor(messagesStream)
final messagesStreamProvider = MessagesStreamFamily._();

/// Live messages for one conversation, oldest → newest.

final class MessagesStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Message>>,
          List<Message>,
          Stream<List<Message>>
        >
    with $FutureModifier<List<Message>>, $StreamProvider<List<Message>> {
  /// Live messages for one conversation, oldest → newest.
  MessagesStreamProvider._({
    required MessagesStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'messagesStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$messagesStreamHash();

  @override
  String toString() {
    return r'messagesStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Message>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Message>> create(Ref ref) {
    final argument = this.argument as String;
    return messagesStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MessagesStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$messagesStreamHash() => r'faabec0bc7037fd9a46d1abd5bce61bc47e0c44c';

/// Live messages for one conversation, oldest → newest.

final class MessagesStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Message>>, String> {
  MessagesStreamFamily._()
    : super(
        retry: null,
        name: r'messagesStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Live messages for one conversation, oldest → newest.

  MessagesStreamProvider call(String conversationId) =>
      MessagesStreamProvider._(argument: conversationId, from: this);

  @override
  String toString() => r'messagesStreamProvider';
}

/// Derives the conversation header (title, updatedAt) from the existing
/// realtime list provider. The Edge Function bumps the title on the first
/// turn; that UPDATE event flows through [conversationsListProvider] and
/// shows up here automatically.

@ProviderFor(conversationById)
final conversationByIdProvider = ConversationByIdFamily._();

/// Derives the conversation header (title, updatedAt) from the existing
/// realtime list provider. The Edge Function bumps the title on the first
/// turn; that UPDATE event flows through [conversationsListProvider] and
/// shows up here automatically.

final class ConversationByIdProvider
    extends $FunctionalProvider<Conversation?, Conversation?, Conversation?>
    with $Provider<Conversation?> {
  /// Derives the conversation header (title, updatedAt) from the existing
  /// realtime list provider. The Edge Function bumps the title on the first
  /// turn; that UPDATE event flows through [conversationsListProvider] and
  /// shows up here automatically.
  ConversationByIdProvider._({
    required ConversationByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'conversationByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$conversationByIdHash();

  @override
  String toString() {
    return r'conversationByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Conversation?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Conversation? create(Ref ref) {
    final argument = this.argument as String;
    return conversationById(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Conversation? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Conversation?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ConversationByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$conversationByIdHash() => r'8e4bec28a308ce7d572b603aa62d70df13a00988';

/// Derives the conversation header (title, updatedAt) from the existing
/// realtime list provider. The Edge Function bumps the title on the first
/// turn; that UPDATE event flows through [conversationsListProvider] and
/// shows up here automatically.

final class ConversationByIdFamily extends $Family
    with $FunctionalFamilyOverride<Conversation?, String> {
  ConversationByIdFamily._()
    : super(
        retry: null,
        name: r'conversationByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Derives the conversation header (title, updatedAt) from the existing
  /// realtime list provider. The Edge Function bumps the title on the first
  /// turn; that UPDATE event flows through [conversationsListProvider] and
  /// shows up here automatically.

  ConversationByIdProvider call(String id) =>
      ConversationByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'conversationByIdProvider';
}

/// True while a `chat` Edge Function call is in flight for this
/// conversation. Drives both the input lock and the typing indicator.

@ProviderFor(IsSending)
final isSendingProvider = IsSendingFamily._();

/// True while a `chat` Edge Function call is in flight for this
/// conversation. Drives both the input lock and the typing indicator.
final class IsSendingProvider extends $NotifierProvider<IsSending, bool> {
  /// True while a `chat` Edge Function call is in flight for this
  /// conversation. Drives both the input lock and the typing indicator.
  IsSendingProvider._({
    required IsSendingFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'isSendingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isSendingHash();

  @override
  String toString() {
    return r'isSendingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  IsSending create() => IsSending();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IsSendingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isSendingHash() => r'00d8954859ac4d9943b85839ce39a48ef03dcfc7';

/// True while a `chat` Edge Function call is in flight for this
/// conversation. Drives both the input lock and the typing indicator.

final class IsSendingFamily extends $Family
    with $ClassFamilyOverride<IsSending, bool, bool, bool, String> {
  IsSendingFamily._()
    : super(
        retry: null,
        name: r'isSendingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// True while a `chat` Edge Function call is in flight for this
  /// conversation. Drives both the input lock and the typing indicator.

  IsSendingProvider call(String conversationId) =>
      IsSendingProvider._(argument: conversationId, from: this);

  @override
  String toString() => r'isSendingProvider';
}

/// True while a `chat` Edge Function call is in flight for this
/// conversation. Drives both the input lock and the typing indicator.

abstract class _$IsSending extends $Notifier<bool> {
  late final _$args = ref.$arg as String;
  String get conversationId => _$args;

  bool build(String conversationId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

/// Optimistic copy of the user's last unsent message. Rendered at the
/// bottom of the message list until the realtime subscription delivers
/// the persisted row from the server (or until the request fails).

@ProviderFor(PendingUserMessage)
final pendingUserMessageProvider = PendingUserMessageFamily._();

/// Optimistic copy of the user's last unsent message. Rendered at the
/// bottom of the message list until the realtime subscription delivers
/// the persisted row from the server (or until the request fails).
final class PendingUserMessageProvider
    extends $NotifierProvider<PendingUserMessage, Message?> {
  /// Optimistic copy of the user's last unsent message. Rendered at the
  /// bottom of the message list until the realtime subscription delivers
  /// the persisted row from the server (or until the request fails).
  PendingUserMessageProvider._({
    required PendingUserMessageFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'pendingUserMessageProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pendingUserMessageHash();

  @override
  String toString() {
    return r'pendingUserMessageProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PendingUserMessage create() => PendingUserMessage();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Message? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Message?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PendingUserMessageProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pendingUserMessageHash() =>
    r'1ae80463a0f52216ae5c1a2a955656c389fd33f3';

/// Optimistic copy of the user's last unsent message. Rendered at the
/// bottom of the message list until the realtime subscription delivers
/// the persisted row from the server (or until the request fails).

final class PendingUserMessageFamily extends $Family
    with
        $ClassFamilyOverride<
          PendingUserMessage,
          Message?,
          Message?,
          Message?,
          String
        > {
  PendingUserMessageFamily._()
    : super(
        retry: null,
        name: r'pendingUserMessageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Optimistic copy of the user's last unsent message. Rendered at the
  /// bottom of the message list until the realtime subscription delivers
  /// the persisted row from the server (or until the request fails).

  PendingUserMessageProvider call(String conversationId) =>
      PendingUserMessageProvider._(argument: conversationId, from: this);

  @override
  String toString() => r'pendingUserMessageProvider';
}

/// Optimistic copy of the user's last unsent message. Rendered at the
/// bottom of the message list until the realtime subscription delivers
/// the persisted row from the server (or until the request fails).

abstract class _$PendingUserMessage extends $Notifier<Message?> {
  late final _$args = ref.$arg as String;
  String get conversationId => _$args;

  Message? build(String conversationId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Message?, Message?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Message?, Message?>,
              Message?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
