import 'package:flutter/material.dart';
import '../models/mood_entry.dart';

class MoodFacePainter extends CustomPainter {
  final Mood mood;
  final double size;

  const MoodFacePainter({required this.mood, required this.size});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final faceRadius = size.width / 2 * 0.8;
    final eyeRadius = faceRadius * 0.12;
    final eyeOffsetX = faceRadius * 0.35;
    final eyeOffsetY = faceRadius * 0.25;

    // Draw face circle
    final facePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, faceRadius, facePaint);

    final borderPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, faceRadius, borderPaint);

    // Draw eyes (same for all moods)
    final eyePaint = Paint()
      ..color = Colors.brown.shade700
      ..style = PaintingStyle.fill;

    // Left eye
    canvas.drawCircle(
      Offset(center.dx - eyeOffsetX, center.dy - eyeOffsetY),
      eyeRadius,
      eyePaint,
    );
    // Right eye
    canvas.drawCircle(
      Offset(center.dx + eyeOffsetX, center.dy - eyeOffsetY),
      eyeRadius,
      eyePaint,
    );

    // Draw mouth based on mood
    final mouthPaint = Paint()
      ..color = Colors.brown.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final mouthRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + faceRadius * 0.2),
      width: faceRadius * 0.7,
      height: faceRadius * 0.5,
    );

    switch (mood) {
      case Mood.happy:
        // Smile: upward arc
        canvas.drawArc(
          mouthRect,
          0,
          3.14,
          false,
          mouthPaint,
        );
        // Add rosy cheeks
        final blushPaint = Paint()
          ..color = Colors.pink.shade100
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(center.dx - eyeOffsetX * 1.2, center.dy + eyeOffsetY * 0.5),
          eyeRadius * 0.8,
          blushPaint,
        );
        canvas.drawCircle(
          Offset(center.dx + eyeOffsetX * 1.2, center.dy + eyeOffsetY * 0.5),
          eyeRadius * 0.8,
          blushPaint,
        );
        break;

      case Mood.neutral:
        // Straight line
        final linePath = Path()
          ..moveTo(center.dx - faceRadius * 0.3, center.dy + faceRadius * 0.2)
          ..lineTo(center.dx + faceRadius * 0.3, center.dy + faceRadius * 0.2);
        canvas.drawPath(linePath, mouthPaint);
        break;

      case Mood.sad:
        // Frown: downward arc (inverted)
        canvas.drawArc(
          mouthRect,
          3.14,
          3.14,
          false,
          mouthPaint,
        );
        // Add downturned eyebrows
        final browPaint = Paint()
          ..color = Colors.brown.shade700
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;

        // Left eyebrow (angled down toward center)
        final leftBrow = Path()
          ..moveTo(
            center.dx - eyeOffsetX - eyeRadius * 0.8,
            center.dy - eyeOffsetY - eyeRadius * 0.5,
          )
          ..quadraticBezierTo(
            center.dx - eyeOffsetX,
            center.dy - eyeOffsetY - eyeRadius * 0.2,
            center.dx - eyeOffsetX + eyeRadius * 0.8,
            center.dy - eyeOffsetY + eyeRadius * 0.3,
          );
        // Right eyebrow (angled down toward center)
        final rightBrow = Path()
          ..moveTo(
            center.dx + eyeOffsetX - eyeRadius * 0.8,
            center.dy - eyeOffsetY + eyeRadius * 0.3,
          )
          ..quadraticBezierTo(
            center.dx + eyeOffsetX,
            center.dy - eyeOffsetY - eyeRadius * 0.2,
            center.dx + eyeOffsetX + eyeRadius * 0.8,
            center.dy - eyeOffsetY - eyeRadius * 0.5,
          );

        canvas.drawPath(leftBrow, browPaint);
        canvas.drawPath(rightBrow, browPaint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant MoodFacePainter oldDelegate) {
    return oldDelegate.mood != mood || oldDelegate.size != size;
  }
}
