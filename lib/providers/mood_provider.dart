import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mood_tracker/models/mood_entry.dart';

class MoodNotifier extends StateNotifier<List<MoodEntry>> {
  MoodNotifier() : super([]);

  void addMood(Mood mood) {
    state = [...state, MoodEntry(date: DateTime.now(), mood: mood)];
  }

  List<MoodEntry> getRecentEntries(int count) {
    final recent = state.reversed.take(count).toList().reversed.toList();
    return recent;
  }
}

final moodProvider =
    StateNotifierProvider<MoodNotifier, List<MoodEntry>>((ref) {
  return MoodNotifier();
});

final recentEntriesProvider =
    Provider.family<List<MoodEntry>, int>((ref, count) {
  final moodNotifier = ref.watch(moodProvider.notifier);
  return moodNotifier.getRecentEntries(count);
});
