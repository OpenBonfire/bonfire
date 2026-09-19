import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc_rs/flutter_webrtc_rs.dart';
import 'package:flutter_webrtc_rs_example/loopback_demo.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => await RustLib.init());

  test(
    'two RtcPeerConnections signal, connect, and exchange data channel messages',
    () async {
      // ignore: avoid_print
      await runLoopbackDemo(print);
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );
}
