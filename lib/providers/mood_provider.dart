import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/mood_entry.dart';

final moodBoxProvider = Provider<Box<MoodEntry>>((ref) {
  return Hive.box<MoodEntry>('mood_entries');
});

final moodEntriesProvider =
    StateNotifierProvider<MoodNotifier, List<MoodEntry>>((ref) {
  final box = ref.watch(moodBoxProvider);
  return MoodNotifier(box);
});

class MoodNotifier extends StateNotifier<List<MoodEntry>> {
  final Box<MoodEntry> box;

  MoodNotifier(this.box)
      : super(box.values.toList()..sort((a, b) => b.date.compareTo(a.date)));

  Future<void> addMood(Mood mood, {String note = ''}) async {
    final entry = MoodEntry(date: DateTime.now(), mood: mood, note: note);
    await box.add(entry);
    state = [entry, ...state];
  }

  List<MoodEntry> getRecentEntries(int count) {
    return state.take(count).toList();
  }

  Map<Mood, int> getMoodStats() {
    final stats = <Mood, int>{};
    for (final entry in state) {
      stats[entry.mood] = (stats[entry.mood] ?? 0) + 1;
    }
    return stats;
  }
}
