import 'dart:convert';

class JournalEntry {
  final String id;
  final String title;
  final String text;
  final String date;
  final String mood;
  final double happyVal;
  final double sadVal;
  final double calmVal;
  final double anxiousVal;
  final String? voiceNotePath;
  final int voiceDurationSec;
  final List<String> bullets;
  final List<String> categories;
  final List<String> imageUrls;
  final List<String> fileNames;

  JournalEntry({
    required this.id,
    required this.title,
    required this.text,
    required this.date,
    required this.mood,
    required this.happyVal,
    required this.sadVal,
    required this.calmVal,
    required this.anxiousVal,
    this.voiceNotePath,
    this.voiceDurationSec = 0,
    this.bullets = const [],
    required this.categories,
    this.imageUrls = const [],
    this.fileNames = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'text': text,
      'date': date,
      'mood': mood,
      'happyVal': happyVal,
      'sadVal': sadVal,
      'calmVal': calmVal,
      'anxiousVal': anxiousVal,
      'voiceNotePath': voiceNotePath,
      'voiceDurationSec': voiceDurationSec,
      'bullets': bullets,
      'categories': categories,
      'imageUrls': imageUrls,
      'fileNames': fileNames,
    };
  }

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      text: map['text'] ?? '',
      date: map['date'] ?? '',
      mood: map['mood'] ?? 'Calm',
      happyVal: (map['happyVal'] as num?)?.toDouble() ?? 0.5,
      sadVal: (map['sadVal'] as num?)?.toDouble() ?? 0.1,
      calmVal: (map['calmVal'] as num?)?.toDouble() ?? 0.5,
      anxiousVal: (map['anxiousVal'] as num?)?.toDouble() ?? 0.1,
      voiceNotePath: map['voiceNotePath'],
      voiceDurationSec: map['voiceDurationSec'] ?? 0,
      bullets: List<String>.from(map['bullets'] ?? []),
      categories: List<String>.from(map['categories'] ?? []),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      fileNames: List<String>.from(map['fileNames'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory JournalEntry.fromJson(String source) => JournalEntry.fromMap(json.decode(source));

  JournalEntry copyWith({
    String? id,
    String? title,
    String? text,
    String? date,
    String? mood,
    double? happyVal,
    double? sadVal,
    double? calmVal,
    double? anxiousVal,
    String? voiceNotePath,
    int? voiceDurationSec,
    List<String>? bullets,
    List<String>? categories,
    List<String>? imageUrls,
    List<String>? fileNames,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      text: text ?? this.text,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      happyVal: happyVal ?? this.happyVal,
      sadVal: sadVal ?? this.sadVal,
      calmVal: calmVal ?? this.calmVal,
      anxiousVal: anxiousVal ?? this.anxiousVal,
      voiceNotePath: voiceNotePath ?? this.voiceNotePath,
      voiceDurationSec: voiceDurationSec ?? this.voiceDurationSec,
      bullets: bullets ?? this.bullets,
      categories: categories ?? this.categories,
      imageUrls: imageUrls ?? this.imageUrls,
      fileNames: fileNames ?? this.fileNames,
    );
  }
}
