class AppConstants {
  static const String journalPrefsKey = 'solace_journal_entries';
  static const String authNameKey = 'solace_auth_name';
  static const String authEmailKey = 'solace_auth_email';
  static const String authProfilePicKey = 'solace_auth_profile_pic';
  static const String authLoggedInKey = 'solace_auth_loggedin';
  static const String themeModeKey = 'solace_dark_theme';

  static const List<String> categories = ['Personal', 'Calm', 'Motivation', 'Work', 'Health', 'Gratitude'];

  static const List<Map<String, String>> promptSuggestions = [
    {
      'title': 'Pause & reflect 🌱',
      'desc': 'What are you most grateful for today?',
      'tag': 'Personal',
    },
    {
      'title': 'Set intentions 🌞',
      'desc': 'How do you want to show up today?',
      'tag': 'Motivation',
    },
    {
      'title': 'Gratitude check ✨',
      'desc': 'Name three tiny things that brought you peace today.',
      'tag': 'Calm',
    },
  ];

  static const List<Map<String, dynamic>> seedEntries = [
    {
      'id': 'seed-1',
      'title': 'Morning Reflection',
      'date': 'March 22, 2025',
      'text': 'I woke up to the soft light filtering through my window, and for the first time in a while, I didn’t rush to check my phone. Instead, I took a deep breath and stretched, feeling my body wake up slowly. The morning routine felt deliberate and peaceful. I brewed a warm cup of herbal tea and just listened to the early morning birds. The stillness was exactly what my mind needed.',
      'mood': 'Calm',
      'happyVal': 0.80,
      'sadVal': 0.10,
      'calmVal': 0.90,
      'anxiousVal': 0.15,
      'voiceNotePath': 'mock_audio_1.wav',
      'voiceDurationSec': 32,
      'bullets': [
        'The warmth of my morning tea',
        'A quiet moment to myself before the day starts',
        'The kindness of a stranger who held the door open for me yesterday'
      ],
      'categories': ['Personal', 'Calm', 'Motivation'],
    },
    {
      'id': 'seed-2',
      'title': 'Grateful for Friends',
      'date': 'March 21, 2025',
      'text': 'Had a long call with Maria today. We haven\'t caught up in months, but speaking to her made me realize that distance doesn\'t fade real connections. We laughed about old college times and shared our current challenges. I felt so supported and understood afterward.',
      'mood': 'Happy',
      'happyVal': 0.95,
      'sadVal': 0.05,
      'calmVal': 0.75,
      'anxiousVal': 0.20,
      'voiceNotePath': null,
      'voiceDurationSec': 0,
      'bullets': [
        'Connecting deeply with Maria',
        'Revisiting cheerful college memories',
        'Feeling a strong sense of belonging and support'
      ],
      'categories': ['Personal', 'Gratitude'],
    }
  ];
}
