import 'package:firebridge/src/models/channel/channel.dart';
import 'package:firebridge/src/models/channel/thread.dart';
import 'package:firebridge/src/models/message/message.dart';
import 'package:firebridge/src/utils/to_string_helper/to_string_helper.dart';

/// {@template thread_list}
/// A list of threads and thread members.
/// {@endtemplate}
class ThreadList with ToStringHelper {
  /// The threads that match the search parameters
  final List<Channel> threads;

  /// A thread member object for each returned thread the current user has joined
  final List<ThreadMember> members;

  /// Whether there are potentially additional threads that could be returned on a subsequent call
  final bool hasMore;

  /// The total number of threads that match the search parameters
  final int totalResults;

  /// The first messages of each thread
  final List<Message> firstMessages;

  ThreadList({
    required this.threads,
    required this.members,
    required this.hasMore,
    required this.totalResults,
    required this.firstMessages,
  });
}
