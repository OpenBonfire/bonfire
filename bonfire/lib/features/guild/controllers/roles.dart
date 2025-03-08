import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'roles.g.dart';

/// Fetches the current roles from [guildId].
@Riverpod(keepAlive: true)
class RolesController extends _$RolesController {
  @override
  List<Snowflake>? build(Snowflake guildId) {
    return null;
  }

  void setRoles(List<Snowflake> roleIds) {
    state = roleIds;
  }
}
