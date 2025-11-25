// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relationships.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RelationshipController)
const relationshipControllerProvider = RelationshipControllerProvider._();

final class RelationshipControllerProvider
    extends $NotifierProvider<RelationshipController, List<Relationship>?> {
  const RelationshipControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'relationshipControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$relationshipControllerHash();

  @$internal
  @override
  RelationshipController create() => RelationshipController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Relationship>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Relationship>?>(value),
    );
  }
}

String _$relationshipControllerHash() =>
    r'abd34714b2c85ad424c26997c3105131071b696e';

abstract class _$RelationshipController extends $Notifier<List<Relationship>?> {
  List<Relationship>? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<Relationship>?, List<Relationship>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Relationship>?, List<Relationship>?>,
              List<Relationship>?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
