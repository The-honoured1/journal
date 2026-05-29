class JournalEntry {
  final String title;
  final String date;
  final String text;
  final List<String> bullets;
  final List<String> categories;

  JournalEntry({
    required this.title,
    required this.date,
    required this.text,
    required this.bullets,
    required this.categories,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date,
      'text': text,
      'bullets': bullets,
      'categories': categories,
    };
  }

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      title: map['title'] ?? '',
      date: map['date'] ?? '',
      text: map['text'] ?? '',
      bullets: List<String>.from(map['bullets'] ?? []),
      categories: List<String>.from(map['categories'] ?? []),
    );
  }
}
