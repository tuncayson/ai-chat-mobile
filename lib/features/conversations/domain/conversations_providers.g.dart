// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversations_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(conversationsRepository)
final conversationsRepositoryProvider = ConversationsRepositoryProvider._();

final class ConversationsRepositoryProvider
    extends
        $FunctionalProvider<
          ConversationsRepository,
          ConversationsRepository,
          ConversationsRepository
        >
    with $Provider<ConversationsRepository> {
  ConversationsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conversationsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conversationsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ConversationsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConversationsRepository create(Ref ref) {
    return conversationsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConversationsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConversationsRepository>(value),
    );
  }
}

String _$conversationsRepositoryHash() =>
    r'807cc2be39d918136058f4b151a743a907837293';

/// Live list of the caller's conversations. Re-subscribes whenever the
/// signed-in user changes so signing out clears the previous user's
/// stream and signing back in produces a fresh subscription.

@ProviderFor(conversationsList)
final conversationsListProvider = ConversationsListProvider._();

/// Live list of the caller's conversations. Re-subscribes whenever the
/// signed-in user changes so signing out clears the previous user's
/// stream and signing back in produces a fresh subscription.

final class ConversationsListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Conversation>>,
          List<Conversation>,
          Stream<List<Conversation>>
        >
    with
        $FutureModifier<List<Conversation>>,
        $StreamProvider<List<Conversation>> {
  /// Live list of the caller's conversations. Re-subscribes whenever the
  /// signed-in user changes so signing out clears the previous user's
  /// stream and signing back in produces a fresh subscription.
  ConversationsListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conversationsListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conversationsListHash();

  @$internal
  @override
  $StreamProviderElement<List<Conversation>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Conversation>> create(Ref ref) {
    return conversationsList(ref);
  }
}

String _$conversationsListHash() => r'b5b6023420606e0837ba4ec34503641b919e3f38';
