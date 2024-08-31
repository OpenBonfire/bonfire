import 'package:firebridge/firebridge.dart';

(String?, String?)? calculatePresenceMessage(List<Activity> activities) {
  if (activities.isEmpty) return null;

  final priorityOrder = [
    ActivityType.custom,
    ActivityType.streaming,
    ActivityType.game,
    ActivityType.listening,
    ActivityType.watching,
    ActivityType.competing
  ];

  var sortedActivities = activities.toList()
    ..sort((a, b) =>
        priorityOrder.indexOf(a.type).compareTo(priorityOrder.indexOf(b.type)));

  Activity highestPriorityActivity = sortedActivities.first;

  switch (highestPriorityActivity.type) {
    case ActivityType.custom:
      return (highestPriorityActivity.state, null);
    case ActivityType.streaming:
      return ("Streaming", highestPriorityActivity.name);
    case ActivityType.game:
      return ("Playing", highestPriorityActivity.name);
    case ActivityType.listening:
      return ("Listening to", highestPriorityActivity.name);
    case ActivityType.watching:
      return ("Watching", highestPriorityActivity.name);
    case ActivityType.competing:
      return ("Competing in", highestPriorityActivity.name);
    default:
      return null;
  }
}
