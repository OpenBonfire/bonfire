import 'package:firebridge_extensions/src/utils/formatters.dart';

/// Extensions on [DateTime].
extension DateTimeExtensions on DateTime {
  /// Formats the [DateTime] into a date string timestamp.
  String format([TimestampStyle style = TimestampStyle.none]) => formatDate(this, style);
}

/// Extensions on [Duration].
extension DurationExtensions on Duration {
  /// Formats the [Duration] into a date string timestamp.
  /// The style will always be relative to represent as a duration on Discord.
  String format() => formatDate(DateTime.now().add(this), TimestampStyle.relativeTime);
}
