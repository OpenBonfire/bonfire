String dateTimeFormat(DateTime time) {
  String section1;
  String section2;

  if (time.day == DateTime.now().day) {
    section1 = 'Today';
  } else if (time.day == DateTime.now().day - 1) {
    section1 = 'Yesterday';
  } else {
    section1 = '${time.month}/${time.day}/${time.year}';
  }

  int twelveHour = time.hour % 12;
  twelveHour = twelveHour == 0 ? 12 : twelveHour;
  String section3 = time.hour >= 12 ? 'PM' : 'AM';

  String formattedMinute = time.minute < 10
      ? '0${time.minute}'
      : '${time.minute}';
  section2 = ' at $twelveHour:$formattedMinute $section3';

  return section1 + section2;
}
