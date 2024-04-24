import 'package:bonfire/shared/models/channel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BonfireIcons {
  static Map<BonfireChannelType, Icon> channelIcons = {
    BonfireChannelType.guildText: const Icon(Icons.tag),
    BonfireChannelType.guildVoice: const Icon(Icons.mic),
    BonfireChannelType.guildCategory: const Icon(Icons.category),
    BonfireChannelType.guildAnnouncement: const Icon(Icons.announcement),
    BonfireChannelType.announcementThread: const Icon(Icons.announcement),
    BonfireChannelType.publicThread: const Icon(Icons.announcement),
    BonfireChannelType.privateThread: const Icon(Icons.announcement),
    BonfireChannelType.guildStageVoice: const Icon(Icons.mic),
    BonfireChannelType.guildDirectory: const Icon(Icons.folder),
    BonfireChannelType.guildForum: const Icon(Icons.forum),
    BonfireChannelType.guildMedia: const Icon(Icons.photo),
  };
}


// hashtag icon