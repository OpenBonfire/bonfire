import 'package:bonfire/features/authenticator/models/added_account.dart';
import 'package:hive_ce/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'added_accounts.g.dart';

@riverpod
class AddedAccountsController extends _$AddedAccountsController {
  @override
  List<AddedAccount> build() {
    final box = Hive.box("added-accounts");
    final List<AddedAccount> accounts = box.values
        .map((e) => AddedAccount.fromJson((e as Map<dynamic, dynamic>)
            .map((key, value) => MapEntry(key.toString(), value.toString()))))
        .toList()
        .cast<AddedAccount>();

    return accounts;
  }
}
