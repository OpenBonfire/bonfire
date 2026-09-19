import 'package:bonfire/features/authentication/repositories/auth.dart';
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'voice_connection.g.dart';

/// The current voice connection, at the gateway level only - no WebRTC/media
/// is involved. This just tracks which channel we've told Discord we want to
/// be in, and the session info Discord sends back once it's confirmed.
class VoiceConnectionState {
  final Snowflake? guildId;
  final Snowflake? channelId;
  final String? sessionId;
  final String? voiceServerToken;
  final String? voiceServerEndpoint;

  const VoiceConnectionState({
    this.guildId,
    this.channelId,
    this.sessionId,
    this.voiceServerToken,
    this.voiceServerEndpoint,
  });

  bool get isConnected => channelId != null;
}

@Riverpod(keepAlive: true)
class VoiceConnectionController extends _$VoiceConnectionController {
  @override
  VoiceConnectionState build() {
    final client = ref.watch(clientControllerProvider);
    if (client == null) return const VoiceConnectionState();

    final voiceStateSub = client.onVoiceStateUpdate.listen(_handleVoiceStateUpdate);
    final voiceServerSub = client.onVoiceServerUpdate.listen(_handleVoiceServerUpdate);
    ref.onDispose(voiceStateSub.cancel);
    ref.onDispose(voiceServerSub.cancel);

    return const VoiceConnectionState();
  }

  /// Tell Discord we want to join [channelId] in [guildId]. Sets [state]
  /// immediately rather than waiting on [_handleVoiceStateUpdate] to confirm
  /// it - that confirmation still arrives and reconciles [state] (it's how
  /// [sessionId] gets filled in), but the UI shouldn't be stuck showing
  /// "not connected" for however long that round-trip takes, and [leave]
  /// needs `state.guildId` to be set right away or it has nothing to send.
  void join(Snowflake guildId, Snowflake channelId) {
    final client = ref.read(clientControllerProvider);
    if (client == null) return;

    state = VoiceConnectionState(guildId: guildId, channelId: channelId);

    client.gateway.updateVoiceState(
      guildId,
      GatewayVoiceStateBuilder(
        channelId: channelId,
        muted: false,
        deafened: false,
      ),
    );
  }

  void leave() {
    final client = ref.read(clientControllerProvider);
    final guildId = state.guildId;

    if (client != null && guildId != null) {
      client.gateway.updateVoiceState(
        guildId,
        GatewayVoiceStateBuilder(
          channelId: null,
          muted: false,
          deafened: false,
        ),
      );
    }

    // Clear unconditionally so leaving always works locally, even if the
    // guild id was somehow missing or the send above didn't go through.
    state = const VoiceConnectionState();
  }

  void _handleVoiceStateUpdate(VoiceStateUpdateEvent event) {
    final client = ref.read(clientControllerProvider);
    if (client == null || event.state.userId != client.user.id) return;

    if (event.state.channelId == null) {
      state = const VoiceConnectionState();
    } else {
      state = VoiceConnectionState(
        guildId: event.state.guildId,
        channelId: event.state.channelId,
        sessionId: event.state.sessionId,
      );
    }
  }

  void _handleVoiceServerUpdate(VoiceServerUpdateEvent event) {
    if (event.guildId != state.guildId) return;

    // Set directly rather than through copyWith - endpoint can legitimately
    // become null (the voice server is being reallocated) and copyWith's
    // `??` would otherwise keep the stale value.
    state = VoiceConnectionState(
      guildId: state.guildId,
      channelId: state.channelId,
      sessionId: state.sessionId,
      voiceServerToken: event.token,
      voiceServerEndpoint: event.endpoint,
    );
  }
}
