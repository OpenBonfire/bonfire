// import 'package:bonfire/features/authentication/repositories/discord_auth.dart';
// import 'package:firebridge/firebridge.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';

// part 'relationships.g.dart';

// @Riverpod(keepAlive: true)
// class RelationshipController extends _$RelationshipController {
//   AuthUser? user;

//   @override
//   List<Relationship>? build() {
//     return null;
//   }

//   void setRelationships(List<Relationship> relationships) {
//     state = relationships;
//   }

//   void addRelationship(Relationship relationship) {
//     state = [...state ?? [], relationship];
//   }

//   void removeRelationship(Snowflake relationshipId) {
//     state = state?.where((r) => r.id != relationshipId).toList();
//   }

//   void updateRelationship(Relationship relationship) {
//     state =
//         state?.map((r) => r.id == relationship.id ? relationship : r).toList();
//   }
// }
