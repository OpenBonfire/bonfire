class DiscordDateUtils {
  static const int DISCORD_EPOCH = 1420070400000;

  static DateTime unpackLastViewed(int lastViewed) {
    return DateTime.fromMillisecondsSinceEpoch(
        DISCORD_EPOCH + lastViewed * 86400000);
  }

  static int packLastViewed(DateTime lastViewed) {
    return ((lastViewed.millisecondsSinceEpoch - DISCORD_EPOCH) / 86400000 +
            0.5)
        .floor();
  }
}
