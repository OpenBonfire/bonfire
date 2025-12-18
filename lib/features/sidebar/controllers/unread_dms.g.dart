// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unread_dms.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UnreadDms)
const unreadDmsProvider = UnreadDmsProvider._();

final class UnreadDmsProvider
    extends $NotifierProvider<UnreadDms, List<ReadState>?> {
  const UnreadDmsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unreadDmsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unreadDmsHash();

  @$internal
  @override
  UnreadDms create() => UnreadDms();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ReadState>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ReadState>?>(value),
    );
  }
}

String _$unreadDmsHash() => r'83c458fada7137d5a980f1baaf6c5f57f6236fc3';

abstract class _$UnreadDms extends $Notifier<List<ReadState>?> {
  List<ReadState>? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<ReadState>?, List<ReadState>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<ReadState>?, List<ReadState>?>,
              List<ReadState>?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
