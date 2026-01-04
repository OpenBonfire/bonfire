
// import 'package:firebridge/firebridge.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:markdown_viewer/markdown_viewer.dart';

// class DiscordMentionSyntax extends MdInlineSyntax {
//   DiscordMentionSyntax() : super(RegExp(r'<(@!?|@&|#)(\d{17,19})>'));

//   @override
//   MdInlineObject? parse(MdInlineParser parser, Match match) {
//     final markers = [parser.consume()];
//     final content = parser.consumeBy(match[0]!.length - 1);
//     final children = content.map((e) => MdText.fromSpan(e)).toList();

//     return MdInlineElement(
//       'discord_mention',
//       markers: markers,
//       children: children,
//       start: markers.first.start,
//       end: children.last.end,
//       attributes: {'type': match[1]!, 'id': match[2]!},
//     );
//   }
// }

// class DiscordMentionBuilder extends MarkdownElementBuilder {
//   DiscordMentionBuilder()
//       : super(
//           textStyle: TextStyle(
//             color: const Color(0xff2448BE),
//             fontWeight: FontWeight.w500,
//             fontSize: 14.5,
//             backgroundColor: const Color(0xff2448BE).withOpacity(0.2),
//           ),
//         );

//   @override
//   bool isBlock(element) => false;

//   @override
//   List<String> get matchTypes => ['discord_mention'];

//   @override
//   void init(MarkdownElement element) {
//     super.init(element);
//   }

//   @override
//   Widget? buildWidget(MarkdownTreeElement element, MarkdownTreeElement parent) {
//     final type = element.attributes['type'];
//     final id = Snowflake.parse(element.attributes['id']!);

//     bool isMember = false;
//     bool isChannel = false;

//     return Consumer(builder: (context, ref, child) {
//       final rawGuildId = GoRouter.of(context)
//           .routerDelegate
//           .currentConfiguration
//           .pathParameters['guildId'];

//       String username = "loading?";

//       Snowflake guildId = Snowflake.parse(rawGuildId ?? '0');
//       if (rawGuildId == "@me") {
//         guildId = Snowflake.zero;
//       }

//       if (type == "@") {
//         isMember = true;
//         final member = ref.watch(getMemberProvider(
//           guildId,
//           id,
//         ));

//         member.when(
//           data: (member) => {
//             username = username = member?.nick ??
//                 member?.user?.globalName ??
//                 member?.user?.username ??
//                 "Unknown User",
//             username = "@$username"
//           },
//           loading: () => {},
//           error: (error, stackTrace) =>
//               debugPrint('Error loading member: $error'),
//         );
//       }

//       if (type == "@&") {
//         final role = ref.watch(getRoleProvider(guildId, id));
//         role.when(
//             data: (role) {
//               username = "@${role.name}";
//             },
//             loading: () => debugPrint('Loading role...'),
//             error: (error, stackTrace) =>
//                 debugPrint('Error loading role: $error'));
//       }

//       if (type == "#") {
//         isChannel = true;
//         final channel =
//             ref.watch(channelControllerProvider(id)) as GuildChannel?;
//         if (channel != null) {
//           username = "#${channel.name}";
//         }
//       }

//       return InkWell(
//         borderRadius: BorderRadius.circular(4),
//         onTap: () {
//           if (isMember) {
//             showMemberDialog(context, id, guildId);
//           } else if (isChannel) {
//             context.go('/channels/$guildId/$id');
//           }
//         },
//         child: Padding(
//           padding: const EdgeInsets.only(top: 2),
//           child: Container(
//             decoration: BoxDecoration(
//               color: BonfireThemeExtension.of(context).primary.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(4),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.only(left: 2, right: 2),
//               child: Text(
//                 username,
//                 style: Theme.of(context).textTheme.bodyMedium!.merge(
//                       const TextStyle(
//                         color: Color.fromARGB(255, 79, 115, 234),
//                       ),
//                     ),
//               ),
//             ),
//           ),
//         ),
//       );
//     });
//   }
// }