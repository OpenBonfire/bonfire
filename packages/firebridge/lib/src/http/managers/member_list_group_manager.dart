// import 'package:firebridge/firebridge.dart';
// import 'package:firebridge/src/models/guild/member_list_group.dart';

// class MemberListGroupManager extends Manager<MemberListGroup> {
//   @override
//   MemberListGroupManager(super.config, super.client, {required this.guildId})
//       : super(identifier: '$guildId.members');

//   @override
//   WritableSnowflakeEntity<MemberListGroup> operator [](Snowflake id) {
//     // TODO: implement []
//     throw UnimplementedError();
//   }

//   @override
//   Future<MemberListGroup> create(
//       covariant CreateBuilder<MemberListGroup> builder) {
//     // TODO: implement create
//     throw UnimplementedError();
//   }

//   @override
//   Future<void> delete(Snowflake id) {
//     // TODO: implement delete
//     throw UnimplementedError();
//   }

//   @override
//   Future<MemberListGroup> fetch(Snowflake id) {
//     // TODO: Create a class that extends NyxxException
//     throw NyxxException(
//         "You cannot fetch the member list due to restrictions in the Discord user API. Please use the Gateway.");
//   }

//   @override
//   MemberListGroup parse(Map<String, Object?> raw) {
//     // TODO: implement parse
//     throw UnimplementedError();
//   }

//   @override
//   Future<MemberListGroup> update(
//       Snowflake id, covariant UpdateBuilder<MemberListGroup> builder) {
//     // TODO: implement update
//     throw UnimplementedError();
//   }
// }
