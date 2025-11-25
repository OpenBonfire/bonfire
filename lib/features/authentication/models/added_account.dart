import 'package:dart_mappable/dart_mappable.dart';

part 'added_account.mapper.dart';

@MappableClass()
class AddedAccount with AddedAccountMappable {
  final String token;
  final String username;
  final String userId;
  final String avatar;
  const AddedAccount({
    required this.token,
    required this.username,
    required this.userId,
    required this.avatar,
  });
}
