import 'package:test/test.dart';
import 'package:firebridge/firebridge.dart';
import 'package:firebridge_extensions/firebridge_extensions.dart';

final baseDate = Snowflake(846136758470443069).timestamp;

void main() {
  group('Timestamp Test', () {
    test(
        'None',
        () => expect(baseDate.format(),
            equals('<t:${baseDate.millisecondsSinceEpoch ~/ 1000}>')));
    test(
        'Short Time',
        () => expect(baseDate.format(TimestampStyle.shortTime),
            equals('<t:${baseDate.millisecondsSinceEpoch ~/ 1000}:t>')));
    test(
        'Long Time',
        () => expect(baseDate.format(TimestampStyle.longTime),
            equals('<t:${baseDate.millisecondsSinceEpoch ~/ 1000}:T>')));
    test(
        'Short Date',
        () => expect(baseDate.format(TimestampStyle.shortDate),
            equals('<t:${baseDate.millisecondsSinceEpoch ~/ 1000}:d>')));
    test(
        'Long Date',
        () => expect(baseDate.format(TimestampStyle.longDate),
            equals('<t:${baseDate.millisecondsSinceEpoch ~/ 1000}:D>')));
    test(
        'Short Date Time',
        () => expect(baseDate.format(TimestampStyle.shortDateTime),
            equals('<t:${baseDate.millisecondsSinceEpoch ~/ 1000}:f>')));
    test(
        'Long Date Time',
        () => expect(baseDate.format(TimestampStyle.longDateTime),
            equals('<t:${baseDate.millisecondsSinceEpoch ~/ 1000}:F>')));
    test(
        'Relative Time',
        () => expect(baseDate.format(TimestampStyle.relativeTime),
            equals('<t:${baseDate.millisecondsSinceEpoch ~/ 1000}:R>')));
  });
}
