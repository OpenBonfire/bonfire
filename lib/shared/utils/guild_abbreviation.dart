String guildAbbreviation(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  if (words.isEmpty) return '';
  return words.map((w) => w[0]).join().toUpperCase();
}
