import 'package:bonfire/shared/models/member.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.g.dart';

@JsonSerializable()
class BonfireMessage {
  final int id;
  final String content;
  final DateTime timestamp;
  final BonfireMember member;

  BonfireMessage({
    required this.id,
    required this.content,
    required this.member,
    required this.timestamp,
  });

  factory BonfireMessage.fromJson(Map<String, dynamic> json) =>
      _$BonfireMessageFromJson(json);

  Map<String, dynamic> toJson() => _$BonfireMessageToJson(this);
}
