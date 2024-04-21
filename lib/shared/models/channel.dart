import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nyxx_self/nyxx.dart';

part 'channel.g.dart';

/// The type of a channel. Taken from nyxx.
enum BonfireChannelType {
  /// A text channel in a [Guild].
  guildText._(0),

  /// A DM channel with a single other recipient.
  dm._(1),

  /// A voice channel in a [Guild].
  guildVoice._(2),

  /// A DM channel with multiple recipients.
  groupDm._(3),

  /// A category in a [Guild].
  guildCategory._(4),

  /// An announcement channel in a [Guild].
  guildAnnouncement._(5),

  /// A [Thread] in an announcement channel.
  announcementThread._(10),

  /// A public thread.
  publicThread._(11),

  /// A private thread.
  privateThread._(12),

  /// A stage channel in a [Guild].
  guildStageVoice._(13),

  /// A [Guild] directory.
  guildDirectory._(14),

  /// A forum channel in a [Guild].
  guildForum._(15),

  /// A media channel in a [Guild].
  guildMedia._(16);

  /// The value of this [ChannelType].
  final int value;

  const BonfireChannelType._(this.value);

  /// Parse a [ChannelType] from a [value].
  ///
  /// The [value] must be a valid channel type.
  factory BonfireChannelType.parse(int value) =>
      BonfireChannelType.values.firstWhere(
        (type) => type.value == value,
        orElse: () => throw FormatException('Unknown channel type', value),
      );

  @override
  String toString() => 'ChannelType($value)';
}

@JsonSerializable()
class BonfireChannel {
  final int id;
  final String name;
  final BonfireChannelType type;
  final int position;
  final BonfireChannel? parent;

  BonfireChannel({
    required this.id,
    required this.name,
    required this.type,
    required this.position,
    this.parent,
  });

  factory BonfireChannel.fromJson(Map<String, dynamic> json) =>
      _$BonfireChannelFromJson(json);

  Map<String, dynamic> toJson() => _$BonfireChannelToJson(this);
}
