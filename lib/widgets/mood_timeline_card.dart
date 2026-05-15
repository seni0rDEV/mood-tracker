import 'package:flutter/material.dart';
import '../models/mood_entry.dart';
import 'mood_face_painter.dart';

class MoodTimelineCard extends StatelessWidget {
  final MoodEntry entry;

  const MoodTimelineCard({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: entry.mood.accentColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: entry.mood.accentColor.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            entry.formattedDate,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: entry.mood.accentColor,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 60,
            height: 60,
            child: CustomPaint(
              painter: MoodFacePainter(mood: entry.mood, size: 60),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 30,
            height: 4,
            decoration: BoxDecoration(
              color: entry.mood.accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
