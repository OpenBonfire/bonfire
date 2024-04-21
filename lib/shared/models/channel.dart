import 'package:freezed_annotation/freezed_annotation.dart';

part 'channel.g.dart';

@JsonSerializable()
class Channel {
  final int id;
  final String name;

  Channel({
    required this.id,
    required this.name,
  });

  factory Channel.fromJson(Map<String, dynamic> json) =>
      _$ChannelFromJson(json);

  Map<String, dynamic> toJson() => _$ChannelToJson(this);
}
