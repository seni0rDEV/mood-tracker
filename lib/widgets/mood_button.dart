import 'package:flutter/material.dart';
import '../models/mood_entry.dart';
import 'mood_face_painter.dart';

class MoodButton extends StatelessWidget {
  final Mood mood;
  final VoidCallback onTap;

  const MoodButton({
    super.key,
    required this.mood,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(40),
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: CustomPaint(
              painter: MoodFacePainter(mood: mood, size: 46),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          mood.displayName,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.deepPurple,
          ),
        ),
      ],
    );
  }
}
