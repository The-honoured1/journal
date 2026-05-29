import 'dart:math' as math;
import 'package:flutter/material.dart';

class SunIllustration extends StatelessWidget {
  const SunIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SunIllustrationPainter(),
    );
  }
}

class SunIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;

    // Draw sky gradient (Warm soft yellow)
    final skyRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final skyGradient = const LinearGradient(
      colors: [
        Color(0xFFFCECD0),
        Color(0xFFFFF6E5),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    paint.shader = skyGradient.createShader(skyRect);
    canvas.drawRect(skyRect, paint);
    paint.shader = null;

    // Draw glowing sun
    final sunCenter = Offset(size.width * 0.5, size.height * 0.72);
    final sunRadius = size.height * 0.3;
    paint.color = const Color(0xFFFFB534);
    canvas.drawCircle(sunCenter, sunRadius, paint);

    // Draw a soft sun core halo
    paint.color = const Color(0xFFFFCE7A);
    canvas.drawCircle(sunCenter, sunRadius * 0.8, paint);

    // Cute smiling face on the sun!
    paint.color = const Color(0xFF785213);
    paint.style = PaintingStyle.fill;
    // Eyes
    canvas.drawCircle(Offset(sunCenter.dx - 10, sunCenter.dy - 6), 2.5, paint);
    canvas.drawCircle(Offset(sunCenter.dx + 10, sunCenter.dy - 6), 2.5, paint);
    // Smile path
    final smilePath = Path()
      ..moveTo(sunCenter.dx - 6, sunCenter.dy + 2)
      ..quadraticBezierTo(
        sunCenter.dx,
        sunCenter.dy + 8,
        sunCenter.dx + 6,
        sunCenter.dy + 2,
      );
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    paint.strokeCap = StrokeCap.round;
    canvas.drawPath(smilePath, paint);

    // Draw green hills
    paint.style = PaintingStyle.fill;

    // Hill 1 (Back left)
    paint.color = const Color(0xFF9ABF7B);
    final path1 = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.84)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.75,
        size.width * 0.65,
        size.height * 0.90,
      )
      ..quadraticBezierTo(
        size.width * 0.8,
        size.height * 0.96,
        size.width,
        size.height * 0.95,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path1, paint);

    // Hill 2 (Front right)
    paint.color = const Color(0xFF7CA65B);
    final path2 = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.95)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.90,
        size.width * 0.5,
        size.height * 0.82,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.74,
        size.width,
        size.height * 0.85,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path2, paint);

    // Pine trees details
    paint.color = const Color(0xFF558233);
    paint.style = PaintingStyle.fill;
    _drawPineTree(canvas, Offset(size.width * 0.15, size.height * 0.78), 24, paint);
    _drawPineTree(canvas, Offset(size.width * 0.08, size.height * 0.81), 18, paint);
    _drawPineTree(canvas, Offset(size.width * 0.84, size.height * 0.80), 20, paint);
    _drawPineTree(canvas, Offset(size.width * 0.92, size.height * 0.83), 16, paint);
  }

  void _drawPineTree(Canvas canvas, Offset base, double height, Paint paint) {
    final path = Path()
      ..moveTo(base.dx, base.dy - height)
      ..lineTo(base.dx - height * 0.25, base.dy)
      ..lineTo(base.dx + height * 0.25, base.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
