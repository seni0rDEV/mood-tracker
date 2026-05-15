import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

enum Mood { happy, neutral, sad, excited, tired }

extension MoodExtension on Mood {
  String get displayName {
    switch (this) {
      case Mood.happy:
        return 'Happy';
      case Mood.neutral:
        return 'Neutral';
      case Mood.sad:
        return 'Sad';
      case Mood.excited:
        return 'Excited';
      case Mood.tired:
        return 'Tired';
    }
  }

  Color get accentColor {
    switch (this) {
      case Mood.happy:
        return Colors.green.shade400;
      case Mood.neutral:
        return Colors.orange.shade400;
      case Mood.sad:
        return Colors.blue.shade400;
      case Mood.excited:
        return Colors.pink.shade400;
      case Mood.tired:
        return Colors.purple.shade400;
    }
  }

  IconData get icon {
    switch (this) {
      case Mood.happy:
        return Icons.sentiment_very_satisfied;
      case Mood.neutral:
        return Icons.sentiment_neutral;
      case Mood.sad:
        return Icons.sentiment_dissatisfied;
      case Mood.excited:
        return Icons.celebration;
      case Mood.tired:
        return Icons.nightlight_round;
    }
  }
}

@HiveType(typeId: 0)
class MoodEntry {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final Mood mood;

  @HiveField(2)
  final String note;

  MoodEntry({
    required this.date,
    required this.mood,
    this.note = '',
  });

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return DateFormat('EEEE').format(date);
    return DateFormat('MMM d').format(date);
  }

  String get fullDate => DateFormat('EEEE, MMMM d, yyyy').format(date);
  String get time => DateFormat('h:mm a').format(date);
}

class MoodEntryAdapter extends TypeAdapter<MoodEntry> {
  @override
  final int typeId = 0;

  @override
  MoodEntry read(BinaryReader reader) {
    return MoodEntry(
      date: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      mood: Mood.values[reader.readInt()],
      note: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, MoodEntry obj) {
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.writeInt(obj.mood.index);
    writer.writeString(obj.note);
  }
}
