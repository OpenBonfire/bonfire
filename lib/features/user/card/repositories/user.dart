import 'package:bonfire/features/authentication/repositories/auth.dart';
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user.g.dart';

/// Get user by id
@riverpod
Future<User> getUserFromId(Ref ref, Snowflake userId) async {
  final client = ref.watch(clientControllerProvider)!;
  return await client.users.get(userId);
}
