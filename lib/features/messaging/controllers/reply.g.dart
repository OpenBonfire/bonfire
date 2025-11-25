// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reply.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ReplyController)
const replyControllerProvider = ReplyControllerProvider._();

final class ReplyControllerProvider
    extends $NotifierProvider<ReplyController, ReplyState?> {
  const ReplyControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'replyControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$replyControllerHash();

  @$internal
  @override
  ReplyController create() => ReplyController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReplyState? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReplyState?>(value),
    );
  }
}

String _$replyControllerHash() => r'9bc3d0ec5dfe8af5bbdd41de4fa5177605cdfaf2';

abstract class _$ReplyController extends $Notifier<ReplyState?> {
  ReplyState? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ReplyState?, ReplyState?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ReplyState?, ReplyState?>,
              ReplyState?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
