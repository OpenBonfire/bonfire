// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'added_accounts.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AddedAccountsController)
final addedAccountsControllerProvider = AddedAccountsControllerProvider._();

final class AddedAccountsControllerProvider
    extends $NotifierProvider<AddedAccountsController, List<AddedAccount>> {
  AddedAccountsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addedAccountsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addedAccountsControllerHash();

  @$internal
  @override
  AddedAccountsController create() => AddedAccountsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<AddedAccount> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<AddedAccount>>(value),
    );
  }
}

String _$addedAccountsControllerHash() =>
    r'849d6877765ebd9786344bd551e8ae451ef6cf49';

abstract class _$AddedAccountsController extends $Notifier<List<AddedAccount>> {
  List<AddedAccount> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<AddedAccount>, List<AddedAccount>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<AddedAccount>, List<AddedAccount>>,
              List<AddedAccount>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
