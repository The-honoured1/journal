import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/journal_entry.dart';
import 'storage_provider.dart';

class JournalNotifier extends StateNotifier<List<JournalEntry>> {
  final Ref _ref;

  JournalNotifier(this._ref) : super([]) {
    _loadEntries();
  }

  void _loadEntries() {
    state = _ref.read(storageServiceProvider).loadEntries();
  }

  Future<void> addEntry(JournalEntry entry) async {
    state = [entry, ...state];
    await _ref.read(storageServiceProvider).saveEntries(state);
  }

  Future<void> updateEntry(JournalEntry updated) async {
    state = [
      for (final entry in state)
        if (entry.id == updated.id) updated else entry
    ];
    await _ref.read(storageServiceProvider).saveEntries(state);
  }

  Future<void> deleteEntry(String id) async {
    state = state.where((entry) => entry.id != id).toList();
    await _ref.read(storageServiceProvider).saveEntries(state);
  }

  // Get cumulative stats for mood tracking
  Map<String, double> getMoodBreakdown() {
    if (state.isEmpty) {
      return {'Happy': 0.25, 'Sad': 0.25, 'Calm': 0.25, 'Anxious': 0.25};
    }
    double happy = 0;
    double sad = 0;
    double calm = 0;
    double anxious = 0;

    for (final e in state) {
      happy += e.happyVal;
      sad += e.sadVal;
      calm += e.calmVal;
      anxious += e.anxiousVal;
    }

    final total = happy + sad + calm + anxious;
    if (total == 0) return {'Happy': 0.25, 'Sad': 0.25, 'Calm': 0.25, 'Anxious': 0.25};

    return {
      'Happy': happy / total,
      'Sad': sad / total,
      'Calm': calm / total,
      'Anxious': anxious / total,
    };
  }

  int getMindfulnessScore() {
    // A gamified mindfulness score calculated from entries and reflections
    return 120 + (state.length * 150);
  }
}

final journalProvider = StateNotifierProvider<JournalNotifier, List<JournalEntry>>((ref) {
  return JournalNotifier(ref);
});
