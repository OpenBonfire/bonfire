import 'package:bonfire/features/authentication/repositories/auth.dart';
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gateway.g.dart';

@Riverpod(keepAlive: true)
class GatewayController extends _$GatewayController {
  FirebridgeGateway? _currentClient;

  @override
  void build() {
    final client = ref.watch(clientControllerProvider);
  }
}
