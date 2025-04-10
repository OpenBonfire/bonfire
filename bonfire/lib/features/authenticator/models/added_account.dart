import 'package:freezed_annotation/freezed_annotation.dart';

part 'added_account.freezed.dart';
part 'added_account.g.dart';

@freezed
class AddedAccount with _$AddedAccount {
  factory AddedAccount({
    required String token,
    required String username,
    required String userId,
    required String avatar,
  }) = _AddedAccount;

  factory AddedAccount.fromJson(Map<String, dynamic> json) =>
      _$AddedAccountFromJson(json);
}
