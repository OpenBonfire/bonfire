// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messagesHash() => r'5cad42967462432909f1e86b6c9a0f6565104c97';

/// Message provider for fetching messages from the Discord API
///
/// Copied from [Messages].
@ProviderFor(Messages)
final messagesProvider =
    AutoDisposeAsyncNotifierProvider<Messages, List<BonfireMessage>>.internal(
  Messages.new,
  name: r'messagesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$messagesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Messages = AutoDisposeAsyncNotifier<List<BonfireMessage>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
