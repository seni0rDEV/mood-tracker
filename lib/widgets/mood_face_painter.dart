import 'dart:math';
import 'package:flutter/material.dart';
import '../models/mood_entry.dart';

class MoodFacePainter extends CustomPainter {
  final Mood mood;
  final double size;
  final bool animated;

  const MoodFacePainter({
    required this.mood,
    required this.size,
    this.animated = false,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final faceRadius = canvasSize.width / 2 * 0.75;
    final eyeRadius = faceRadius * (animated ? 0.14 : 0.12);
    final eyeOffsetX = faceRadius * 0.35;
    final eyeOffsetY = faceRadius * 0.25;

    // Animated pulse effect
    final pulse = animated
        ? 1.0 + sin(DateTime.now().millisecondsSinceEpoch / 200) * 0.05
        : 1.0;

    // Face background with gradient
    final gradient = RadialGradient(
      colors: [
        Colors.white,
        mood.accentColor.withOpacity(0.1),
      ],
      center: Alignment.center,
      radius: 0.8,
    );

    final facePaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: faceRadius * pulse),
      )
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, faceRadius * pulse, facePaint);

    // Face border
    final borderPaint = Paint()
      ..color = mood.accentColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, faceRadius * pulse, borderPaint);

    // Eyes based on mood
    _drawEyes(canvas, center, eyeOffsetX, eyeOffsetY, eyeRadius, faceRadius);

    // Mouth based on mood
    _drawMouth(canvas, center, faceRadius);

    // Additional details for specific moods
    _drawDetails(canvas, center, faceRadius, eyeOffsetX, eyeOffsetY);
  }

  void _drawEyes(Canvas canvas, Offset center, double offsetX, double offsetY,
      double radius, double faceRadius) {
    final eyePaint = Paint()
      ..color = Colors.brown.shade800
      ..style = PaintingStyle.fill;

    final leftEyeCenter = Offset(center.dx - offsetX, center.dy - offsetY);
    final rightEyeCenter = Offset(center.dx + offsetX, center.dy - offsetY);

    switch (mood) {
      case Mood.happy:
        // Happy: squinting eyes (arcs)
        const squintAngle = 0.2;
        canvas.drawArc(
          Rect.fromCircle(center: leftEyeCenter, radius: radius * 1.3),
          squintAngle,
          pi - squintAngle * 2,
          false,
          eyePaint
            ..style = PaintingStyle.stroke
            ..strokeWidth = radius * 0.8,
        );
        canvas.drawArc(
          Rect.fromCircle(center: rightEyeCenter, radius: radius * 1.3),
          squintAngle,
          pi - squintAngle * 2,
          false,
          eyePaint,
        );
        break;

      case Mood.excited:
        // Excited: star-shaped eyes
        _drawStarEye(canvas, leftEyeCenter, radius);
        _drawStarEye(canvas, rightEyeCenter, radius);
        break;

      case Mood.tired:
        // Tired: half-closed eyes
        final tiredPaint = Paint()..color = Colors.brown.shade800;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: leftEyeCenter, width: radius * 2.5, height: radius),
            Radius.circular(radius * 0.5),
          ),
          tiredPaint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: rightEyeCenter, width: radius * 2.5, height: radius),
            Radius.circular(radius * 0.5),
          ),
          tiredPaint,
        );
        break;

      default:
        // Normal circles
        canvas.drawCircle(leftEyeCenter, radius, eyePaint);
        canvas.drawCircle(rightEyeCenter, radius, eyePaint);

        // Add pupils
        if (mood == Mood.sad) {
          final pupilPaint = Paint()..color = Colors.white;
          canvas.drawCircle(
            Offset(leftEyeCenter.dx - radius * 0.3, leftEyeCenter.dy),
            radius * 0.4,
            pupilPaint,
          );
          canvas.drawCircle(
            Offset(rightEyeCenter.dx - radius * 0.3, rightEyeCenter.dy),
            radius * 0.4,
            pupilPaint,
          );
        }
    }
  }

  void _drawStarEye(Canvas canvas, Offset center, double radius) {
    final starPaint = Paint()..color = Colors.amber.shade600;
    for (int i = 0; i < 4; i++) {
      final angle = i * pi / 2;
      final point = Offset(
        center.dx + cos(angle) * radius * 1.2,
        center.dy + sin(angle) * radius * 1.2,
      );
      canvas.drawCircle(point, radius * 0.3, starPaint);
    }
    canvas.drawCircle(center, radius * 0.6, starPaint);
  }

  void _drawMouth(Canvas canvas, Offset center, double faceRadius) {
    final mouthPaint = Paint()
      ..color = Colors.brown.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final mouthRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + faceRadius * 0.25),
      width: faceRadius * 0.6,
      height: faceRadius * 0.4,
    );

    switch (mood) {
      case Mood.happy:
        canvas.drawArc(mouthRect, 0, pi, false, mouthPaint);
        break;

      case Mood.excited:
        canvas.drawArc(mouthRect, 0, pi, false, mouthPaint);
        // Add tongue
        final tonguePaint = Paint()..color = Colors.red.shade300;
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(center.dx, center.dy + faceRadius * 0.3),
            width: faceRadius * 0.2,
            height: faceRadius * 0.15,
          ),
          0,
          pi,
          true,
          tonguePaint,
        );
        break;

      case Mood.neutral:
        final linePath = Path()
          ..moveTo(center.dx - faceRadius * 0.3, center.dy + faceRadius * 0.25)
          ..lineTo(center.dx + faceRadius * 0.3, center.dy + faceRadius * 0.25);
        canvas.drawPath(linePath, mouthPaint);
        break;

      case Mood.sad:
        canvas.drawArc(mouthRect, pi, pi, false, mouthPaint);
        break;

      case Mood.tired:
        final tiredPath = Path()
          ..moveTo(center.dx - faceRadius * 0.35, center.dy + faceRadius * 0.2)
          ..quadraticBezierTo(
            center.dx,
            center.dy + faceRadius * 0.35,
            center.dx + faceRadius * 0.35,
            center.dy + faceRadius * 0.2,
          );
        canvas.drawPath(tiredPath, mouthPaint);
        break;
    }
  }

  void _drawDetails(Canvas canvas, Offset center, double faceRadius,
      double offsetX, double offsetY) {
    switch (mood) {
      case Mood.happy:
        // Rosy cheeks
        final blushPaint = Paint()
          ..color = Colors.pink.shade200
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(center.dx - offsetX * 1.3, center.dy + offsetY * 0.3),
          faceRadius * 0.1,
          blushPaint,
        );
        canvas.drawCircle(
          Offset(center.dx + offsetX * 1.3, center.dy + offsetY * 0.3),
          faceRadius * 0.1,
          blushPaint,
        );
        break;

      case Mood.sad:
        // Tear drop
        final tearPaint = Paint()..color = Colors.blue.shade300;
        final tearPath = Path()
          ..moveTo(center.dx + offsetX * 1.5, center.dy + offsetY)
          ..quadraticBezierTo(
            center.dx + offsetX * 1.7,
            center.dy + offsetY * 1.3,
            center.dx + offsetX * 1.5,
            center.dy + offsetY * 1.5,
          )
          ..quadraticBezierTo(
            center.dx + offsetX * 1.3,
            center.dy + offsetY * 1.3,
            center.dx + offsetX * 1.5,
            center.dy + offsetY,
          );
        canvas.drawPath(tearPath, tearPaint);
        break;

      default:
        break;
    }
  }

  @override
  bool shouldRepaint(covariant MoodFacePainter oldDelegate) {
    return oldDelegate.mood != mood || oldDelegate.animated != animated;
  }
}
