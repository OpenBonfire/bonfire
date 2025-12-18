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

String _$userMessagesHash() => r'25da1550a768b62e067934dc430d270a16a7f938';

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
