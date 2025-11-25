// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_list.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MemberListVisibility)
const memberListVisibilityProvider = MemberListVisibilityProvider._();

final class MemberListVisibilityProvider
    extends $NotifierProvider<MemberListVisibility, bool> {
  const MemberListVisibilityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'memberListVisibilityProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$memberListVisibilityHash();

  @$internal
  @override
  MemberListVisibility create() => MemberListVisibility();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$memberListVisibilityHash() =>
    r'd0c3c92fd359b44b5aac32a8a596f70862921465';

abstract class _$MemberListVisibility extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
