import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'role.g.dart';

/// Gets the role from [roleId].
@Riverpod(keepAlive: true)
class RoleController extends _$RoleController {
  @override
  Role? build(Snowflake roleId) {
    return null;
  }

  void setRole(Role role) {
    state = role;
  }
}
