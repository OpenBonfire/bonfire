import 'package:firebridge/src/models/gateway/event.dart';
import 'package:firebridge/src/models/snowflake.dart';
import 'package:firebridge/src/models/user/relationship.dart';

/// {@template relationship_add_event}
/// Emitted when a relationship is added.
/// {@endtemplate}
class RelationshipAddEvent extends DispatchEvent {
  /// The relationship that was added
  final Relationship relationship;

  /// Whether the client should notify the user of this relationship's creation
  final bool? shouldNotify;

  RelationshipAddEvent({
    required super.gateway,
    required this.relationship,
    this.shouldNotify,
  });
}

/// {@template relationship_remove_event}
/// Emitted when a relationship is removed.
/// {@endtemplate}
class RelationshipRemoveEvent extends DispatchEvent {
  /// The ID of the target user
  final Snowflake id;

  /// The type of relationship
  final int type;

  /// The nickname of the user in this relationship (1-32 characters)
  final String nickname;

  RelationshipRemoveEvent({
    required super.gateway,
    required this.id,
    required this.type,
    required this.nickname,
  });
}

/// {@template relationship_update_event}
/// Emitted when a relationship is updated.
/// {@endtemplate}
class RelationshipUpdateEvent extends DispatchEvent {
  /// The ID of the target user
  final Snowflake id;

  /// The type of relationship
  final int type;

  /// The nickname of the user in this relationship (1-32 characters)
  final String nickname;

  RelationshipUpdateEvent({
    required super.gateway,
    required this.id,
    required this.type,
    required this.nickname,
  });
}
