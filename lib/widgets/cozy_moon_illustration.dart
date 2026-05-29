import 'dart:math' as math;
import 'package:flutter/material.dart';

class CozyMoonIllustration extends StatelessWidget {
  const CozyMoonIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CozyMoonPainter(),
    );
  }
}

class CozyMoonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;

    // Draw deep night sky gradient
    final skyRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final skyGradient = const LinearGradient(
      colors: [
        Color(0xFF1E172A),
        Color(0xFF382956),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    paint.shader = skyGradient.createShader(skyRect);
    canvas.drawRect(skyRect, paint);
    paint.shader = null;

    // Draw tiny stars
    paint.color = Colors.white.withOpacity(0.5);
    final random = math.Random(42);
    for (int i = 0; i < 15; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height * 0.6;
      final r = random.nextDouble() * 1.5 + 0.5;
      canvas.drawCircle(Offset(x, y), r, paint);
    }

    // Draw crescent moon
    final moonCenter = Offset(size.width * 0.78, size.height * 0.35);
    const moonRadius = 26.0;

    // Moon halo
    paint.color = const Color(0xFFFFCE7A).withOpacity(0.12);
    canvas.drawCircle(moonCenter, moonRadius + 12, paint);

    // Moon body
    paint.color = const Color(0xFFFFB534);
    final moonPath = Path()
      ..addArc(Rect.fromCircle(center: moonCenter, radius: moonRadius), -math.pi * 0.5, math.pi * 1.25)
      ..arcToPoint(
        Offset(moonCenter.dx, moonCenter.dy - moonRadius),
        radius: const Radius.circular(moonRadius * 1.15),
        clockwise: false,
      );
    canvas.drawPath(moonPath, paint);

    // Sleeping eye
    paint.color = const Color(0xFF332049);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;
    final eyePath = Path()
      ..moveTo(moonCenter.dx + 4, moonCenter.dy - 4)
      ..quadraticBezierTo(
        moonCenter.dx + 8,
        moonCenter.dy,
        moonCenter.dx + 12,
        moonCenter.dy - 4,
      );
    canvas.drawPath(eyePath, paint);

    // Night hills
    paint.style = PaintingStyle.fill;
    paint.color = const Color(0xFF130E1F);

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.88)
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.80,
        size.width * 0.75,
        size.height * 0.91,
      )
      ..quadraticBezierTo(
        size.width * 0.9,
        size.height * 0.94,
        size.width,
        size.height * 0.92,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);

    // Front dark hill
    paint.color = const Color(0xFF221735);
    final path2 = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.95)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.91,
        size.width * 0.5,
        size.height * 0.86,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.82,
        size.width,
        size.height * 0.88,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
