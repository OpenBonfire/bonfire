// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_messages.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Message provider for fetching user messages from the Discord API

@ProviderFor(UserMessages)
const userMessagesProvider = UserMessagesProvider._();

/// Message provider for fetching user messages from the Discord API
final class UserMessagesProvider
    extends $AsyncNotifierProvider<UserMessages, void> {
  /// Message provider for fetching user messages from the Discord API
  const UserMessagesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userMessagesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userMessagesHash();

  @$internal
  @override
  UserMessages create() => UserMessages();
}

String _$userMessagesHash() => r'c5c84aeede0577efbc25947d1f0319a264ad5f91';

/// Message provider for fetching user messages from the Discord API

abstract class _$UserMessages extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
