import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BonfireIcons {
  static Map<ChannelType, Icon> channelIcons = {
    ChannelType.guildText: const Icon(Icons.tag),
    ChannelType.guildVoice: const Icon(Icons.volume_up),
    ChannelType.guildCategory: const Icon(Icons.category),
    ChannelType.guildAnnouncement: const Icon(Icons.announcement),
    ChannelType.announcementThread: const Icon(Icons.announcement),
    ChannelType.publicThread: const Icon(Icons.announcement),
    ChannelType.privateThread: const Icon(Icons.announcement),
    ChannelType.guildStageVoice: const Icon(Icons.interpreter_mode),
    ChannelType.guildDirectory: const Icon(Icons.folder),
    ChannelType.guildForum: const Icon(Icons.forum),
    ChannelType.guildMedia: const Icon(Icons.photo),
  };
}