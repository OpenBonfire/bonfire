// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_bar.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// State notifier to bound to overlapping panels navigation

@ProviderFor(NavigationBar)
const navigationBarProvider = NavigationBarProvider._();

/// State notifier to bound to overlapping panels navigation
final class NavigationBarProvider
    extends $NotifierProvider<NavigationBar, RevealSide> {
  /// State notifier to bound to overlapping panels navigation
  const NavigationBarProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'navigationBarProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$navigationBarHash();

  @$internal
  @override
  NavigationBar create() => NavigationBar();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RevealSide value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RevealSide>(value),
    );
  }
}

String _$navigationBarHash() => r'bf41b083d3e5aeabc42adb0fa5c7a3040c1e2d51';

/// State notifier to bound to overlapping panels navigation

abstract class _$NavigationBar extends $Notifier<RevealSide> {
  RevealSide build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<RevealSide, RevealSide>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RevealSide, RevealSide>,
              RevealSide,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
