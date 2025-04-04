import 'package:firebridge/src/models/channel/channel.dart';

/// {@template directory_channel}
/// A directory channel.
/// {@endtemplate}
class DirectoryChannel extends Channel {
  @override
  ChannelType get type => ChannelType.guildDirectory;

  /// {@macro directory_channel}
  /// @nodoc
  DirectoryChannel({required super.id, required super.manager});
}
