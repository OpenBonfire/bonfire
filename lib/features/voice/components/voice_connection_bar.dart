import 'package:bonfire/features/gateway/store/entity_store.dart';
import 'package:bonfire/features/voice/components/voice_video_overlay.dart';
import 'package:bonfire/features/voice/controllers/voice_connection.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A persistent bar with a way to leave the current voice channel. Shown
/// regardless of which guild/channel screen is open, since the connected
/// channel's own button may not even be on screen to tap again.
class VoiceConnectionBar extends ConsumerWidget {
  const VoiceConnectionBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(voiceConnectionControllerProvider);
    final connectedChannelId = connectionState.channelId;
    if (connectedChannelId == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final channel = ref.watch(channelProvider(connectedChannelId));
    final channelName = channel is GuildChannel
        ? channel.name
        : connectedChannelId.toString();
    final statusText = _statusText(connectionState);

    return Container(
      width: 350,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: theme.colorScheme.surfaceContainer),
      child: Row(
        children: [
          Icon(
            Icons.volume_up_rounded,
            size: 18,
            color: theme.colorScheme.onSurface,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  channelName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (statusText != null)
                  Text(
                    statusText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          connectionState.mediaStatus == VoiceMediaStatus.failed
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          if (connectionState.mediaStatus == VoiceMediaStatus.connected && voiceUseWebRtcTransport)
            IconButton(
              icon: const Icon(Icons.videocam_outlined, size: 18),
              tooltip: 'Test video streaming',
              onPressed: () => VoiceVideoOverlay.show(context),
            ),
          TextButton(
            onPressed: () {
              ref.read(voiceConnectionControllerProvider.notifier).leave();
            },
            child: const Text("Leave"),
          ),
        ],
      ),
    );
  }

  String? _statusText(VoiceConnectionState state) {
    switch (state.mediaStatus) {
      case VoiceMediaStatus.idle:
        return null;
      case VoiceMediaStatus.connectingGateway:
        return "Connecting…";
      case VoiceMediaStatus.negotiating:
        return "Negotiating…";
      case VoiceMediaStatus.connected:
        return "Voice connected";
      case VoiceMediaStatus.failed:
        return state.mediaError ?? "Voice connection failed";
    }
  }
}
