// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messagesHash() => r'c99ab64eed31569d4a349fa26cfcff2eef86ed24';

/// Message provider for fetching messages from the Discord API
///
/// Copied from [Messages].
@ProviderFor(Messages)
final messagesProvider =
    AutoDisposeAsyncNotifierProvider<Messages, List<Message>>.internal(
  Messages.new,
  name: r'messagesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$messagesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Messages = AutoDisposeAsyncNotifier<List<Message>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
