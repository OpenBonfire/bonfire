// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'package:universal_io/io.dart';
import 'dart:math';

import 'package:bonfire/features/authenticator/data/repositories/auth.dart';
import 'package:bonfire/features/authenticator/qr/key_pair.dart';
import 'package:bonfire/features/authenticator/qr/ws_impl.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

import 'package:webcrypto/webcrypto.dart';

class AuthByQRcode extends ConsumerStatefulWidget {
  static const LOGIN_STATE_DEFAULT = 0;
  static const LOGIN_STATE_QR_CODE = 1;
  static const LOGIN_STATE_USER_PROFILE = 2;

  const AuthByQRcode({super.key});

  @override
  ConsumerState<AuthByQRcode> createState() => _AuthByQRcodeState();
}

class _AuthByQRcodeState extends ConsumerState<AuthByQRcode> {
  bool acked = true;
  WebSocketChannel? channel;
  Timer? timoutId;
  Timer? intervalId;
  Timer? reconTimer;

  int step = AuthByQRcode.LOGIN_STATE_DEFAULT;
  String? nfingerprint;
  Map<String, String?>? userData;

  bool endOfLogin = false;
  bool ended = false;
  bool requestForHCapcha = false;

  @override
  void initState() {
    super.initState();

    endOfLogin = false;

    connect();
  }

  @override
  void dispose() {
    ended = true;

    channel?.sink.close();

    timoutId?.cancel();
    intervalId?.cancel();
    reconTimer?.cancel();

    super.dispose();
  }

  _reconnect() {
    if (reconTimer != null) {
      return;
    }

    setState(() {
      step = AuthByQRcode.LOGIN_STATE_DEFAULT;
    });

    reconTimer = Timer(const Duration(seconds: 5), () {
      reconTimer = null;
      connect();
    });
  }

  _sendMessage(WebSocketChannel channel, Object data) {
    final String jsonString = jsonEncode(data);
    // debugPrint("Send message $jsonString");
    channel.sink.add(jsonString);
  }

  _sendHeardbeat() {
    if (acked) {
      acked = false;
      _sendMessage(channel!, {'op': "heartbeat"});
    } else {
      debugPrint("heartbeat timeout, reconnecting.");
      channel?.sink.close();
      _reconnect();
    }
  }

  _acceptTicket(KeyPair<RsaOaepPrivateKey, RsaOaepPublicKey> keyPair,
      String ticket) async {
    try {
      final response = await http.post(
          Uri.parse("https://discord.com/api/v9/users/@me/remote-auth/login"),
          headers: {HttpHeaders.contentTypeHeader: "application/json"},
          body: jsonEncode({
            "ticket": ticket.trim(),
          }));

      final data = jsonDecode(response.body);

      final encrypted_token = data["encrypted_token"];

      final token = await DiscordKeyPair.decryptEncodedCiphertext(
          keyPair, encrypted_token);

      debugPrint("Got token: $token");

      ref.read(authProvider.notifier).loginWithToken(token);

      // GetIt.I<SettingsStore>().setApiToken(token).then((value) {
      //   endOfLogin = true;
      //   channel?.sink.close();
      //   context.goNamed('Server');
      // });
    } catch (e, _) {
      //   }on DioError catch (e) { <<<<< IN THIS LINE
      //   if(e.response.statusCode == 404){
      //     debugPrint(e.response.statusCode);
      //   }else{
      //     debugPrint(e.message);
      //     debugPrint(e.request);
      //   }
      // }

      // if (e is DioException) {
      //   //handle DioError here by error type or by error code
      //   debugPrint('DioException ${e.response?.statusCode}');

      //   setState(() {
      //     requestForHCapcha = true;
      //   });
      // } else {}

      // GetIt.I<Talker>().handle(e, st);
    }
  }

  int getTimeNow() {
    return (DateTime.now().millisecondsSinceEpoch / 1000).toInt();
  }

  void connect() async {
    final wsUrl = Uri.parse('wss://remote-auth-gateway.discord.gg/?v=2');

    channel?.sink.close();

    int start0 = getTimeNow();

    channel = await createWebSocket(wsUrl);

    debugPrint("Elapsed.0=${getTimeNow() - start0}");

    try {
      await channel!.ready;

      acked = true;

      requestForHCapcha = false;

      debugPrint("Ready");

      debugPrint("Elapsed.1=${getTimeNow() - start0}");

      final keyPair = await DiscordKeyPair.generateRsaKeyPair();

      debugPrint("Elapsed.2=${getTimeNow() - start0}");

      final publicKey = await DiscordKeyPair.serializePublicKey(keyPair);

      debugPrint("Elapsed.3=${getTimeNow() - start0}");

      final fingerprint =
          await DiscordKeyPair.publicKeyFingerdebugPrint(keyPair);

      debugPrint("Elapsed.4=${getTimeNow() - start0}");

      channel!.stream.listen((data) async {
        final map = jsonDecode(data) as Map<String, dynamic>;

        if (map["op"] == "hello") {
          final int hb_interval = map["heartbeat_interval"];

          _sendMessage(
              channel!, {"op": "init", "encoded_public_key": publicKey});

          final int hb_interval0 = (hb_interval * Random().nextDouble()).ceil();

          debugPrint("hb_interval0=$hb_interval0");

          timoutId = Timer(Duration(milliseconds: hb_interval0), () {
            timoutId = null;
            int lastHeartbeat = getTimeNow();
            intervalId =
                Timer.periodic(const Duration(microseconds: 500), (timer) {
              if (getTimeNow() - lastHeartbeat > hb_interval) {
                lastHeartbeat = getTimeNow();
                _sendHeardbeat();
              }
            });
          });
        } else if (map["op"] == "nonce_proof") {
          final encrypted_nonce = map["encrypted_nonce"];

          DiscordKeyPair.decryptNonce(keyPair, encrypted_nonce).then((nonce) {
            _sendMessage(channel!, {"op": "nonce_proof", "nonce": nonce});
          });
        } else if (map["op"] == "pending_remote_init") {
          final localFingerprint = map["fingerprint"];

          if (fingerprint == localFingerprint) {
            setState(() {
              step = AuthByQRcode.LOGIN_STATE_QR_CODE;
              nfingerprint = "https://discord.com/ra/${fingerprint}";
            });
          }
        } else if (map["op"] == "pending_ticket") {
          final encrypted_user_payload = map["encrypted_user_payload"];

          DiscordKeyPair.decodeEncodedUserRecord(
                  keyPair, encrypted_user_payload)
              .then((userData0) {
            setState(() {
              step = AuthByQRcode.LOGIN_STATE_USER_PROFILE;
              userData = userData0;
            });
          });
        } else if (map["op"] == "pending_login") {
          final ticket = map["ticket"];

          debugPrint("pending_login.ticket=${ticket}");
          if (ticket != null) {
            //https://discord.com/api/v9/users/@me/remote-auth/login
            _acceptTicket(keyPair, ticket);
          }
        } else if (map["op"] == "pending_finish") {
          // final encrypted_user_payload = map["encrypted_user_payload"];

          // final userData0 = await DiscordKeyPair.decodeEncodedUserRecord(
          //     keyPair, encrypted_user_payload);

          // debugPrint("userData=${userData0}");

          // setState(() {
          //   step = LoginPage.LOGIN_STATE_USER_PROFILE;
          //   userData = userData0;
          // });
        } else if (map["op"] == "finish") {
          // final encrypted_token = map["encrypted_token"];

          // final n = await DiscordKeyPair.decryptEncodedCiphertext(
          //     keyPair, encrypted_token);

          //
        } else if (map["op"] == "cancel") {
          setState(() {
            step = AuthByQRcode.LOGIN_STATE_DEFAULT;
            channel?.sink.close();
            connect();
          });
        } else if (map["op"] == "heartbeat_ack") {
          acked = true;
        }

        // debugPrint("Message = ${map}");
      }, onError: (error) {
        debugPrint(error);
      }, onDone: () {
        debugPrint(
            "Login connection closed ${channel?.closeCode}, ${channel?.closeReason}");

        if (ended) return;

        timoutId?.cancel();
        timoutId = null;

        intervalId?.cancel();
        intervalId = null;

        if (endOfLogin) return;

        _reconnect();
      });
    } catch (e, st) {
      debugPrint("some error: $st");
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthRemote(
        step: step,
        requestForHCapcha: requestForHCapcha,
        nfingerprint: nfingerprint,
        userData: userData,
        onClick: () {
          channel?.sink.close();
          _reconnect();
        });
  }
}

class AuthRemote extends StatefulWidget {
  const AuthRemote(
      {super.key,
      required this.step,
      required this.requestForHCapcha,
      this.nfingerprint,
      this.userData,
      this.onClick});

  final int step;
  final String? nfingerprint;
  final bool requestForHCapcha;
  final Map<String, String?>? userData;
  final Function? onClick;

  @override
  State<AuthRemote> createState() => _AuthRemoteState();
}

class _AuthRemoteState extends State<AuthRemote> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget w;

    debugPrint("AuthRemote=${widget.step}, userData=${widget.userData}");

    if (widget.step == AuthByQRcode.LOGIN_STATE_QR_CODE) {
      w = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(24)),
                child: QrImageView(
                  padding: const EdgeInsets.all(16.0),
                  dataModuleStyle: QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.circle,
                      color: theme.custom.colorTheme.dirtyWhite),
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.circle,
                    color: theme.custom.colorTheme.dirtyWhite,
                  ),
                  backgroundColor: theme.custom.colorTheme.foreground,
                  data: widget.nfingerprint!,
                  version: QrVersions.auto,
                ),
              ),
            ),
          ]);
    } else if (widget.step == AuthByQRcode.LOGIN_STATE_DEFAULT) {
      w = const SizedBox(child: Center(child: CircularProgressIndicator()));
    } else if (widget.step == AuthByQRcode.LOGIN_STATE_USER_PROFILE) {
      w = Column(children: [
        Container(
          width: 80.0,
          height: 80.0,
          decoration: BoxDecoration(
            color: Colors.transparent,
            image: DecorationImage(
              image: CachedNetworkImageProvider(
                  "https://cdn.discordapp.com/avatars/${widget.userData!["id"]}/${widget.userData!["avatar"]}.webp?size=128"),
              fit: BoxFit.cover,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(50.0)),
            border: Border.all(
              color: Theme.of(context).custom.colorTheme.background,
              width: 6.0,
            ),
          ),
        ),
        Text("Check your phone!",
            style: theme.textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.white)),
        const SizedBox(height: 20),
        Text("Вход: ${widget.userData!["username"]}",
            style: theme.textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 20),
        TextButton(
          child: Text(
            "It's not me, try again",
            style: theme.textTheme.bodyMedium!
                .copyWith(fontSize: 14, color: Colors.lightBlue),
          ),
          onPressed: () {
            if (widget.onClick != null) {
              widget.onClick!();
            }
          },
        ),
        const SizedBox(height: 10),
        widget.requestForHCapcha
            ? Text(
                "Hcapcha request required...",
                style: theme.textTheme.bodyMedium!
                    .copyWith(fontSize: 14, color: Colors.red),
              )
            : Container()
      ]);
    } else {
      w = Container();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // const SizedBox(height: 20),
        w,
      ],
    );
  }
}
