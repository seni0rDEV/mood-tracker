import 'package:flutter/material.dart';

enum Mood { happy, neutral, sad }

extension MoodExtension on Mood {
  String get displayName {
    switch (this) {
      case Mood.happy:
        return 'Happy';
      case Mood.neutral:
        return 'Neutral';
      case Mood.sad:
        return 'Sad';
    }
  }

  Color get accentColor {
    switch (this) {
      case Mood.happy:
        return Colors.green;
      case Mood.neutral:
        return Colors.orange;
      case Mood.sad:
        return Colors.blueGrey;
    }
  }
}

class MoodEntry {
  final DateTime date;
  final Mood mood;

  MoodEntry({required this.date, required this.mood});

  String get formattedDate {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${date.day}/${date.month}';
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'mood': mood.index,
    };
  }

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      date: DateTime.parse(json['date']),
      mood: Mood.values[json['mood']],
    );
  }
}
