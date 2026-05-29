import 'dart:math' as math;
import 'package:flutter/material.dart';

class AudioWaveform extends StatelessWidget {
  final double progress;
  final bool isPlaying;

  const AudioWaveform({
    super.key,
    required this.progress,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: AudioWaveformPainter(
        progress: progress,
        isPlaying: isPlaying,
      ),
    );
  }
}

class AudioWaveformPainter extends CustomPainter {
  final double progress;
  final bool isPlaying;

  AudioWaveformPainter({required this.progress, required this.isPlaying});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    const double barWidth = 3.0;
    const double barGap = 2.0;
    final int barCount = (size.width / (barWidth + barGap)).floor();

    final math.Random random = math.Random(1337);
    final List<double> baseHeights = List.generate(barCount, (index) {
      final normalizedIndex = index / barCount;
      final bellFactor = math.sin(normalizedIndex * math.pi);
      final noise = random.nextDouble() * 0.4 + 0.3;
      return (bellFactor * noise) * size.height;
    });

    for (int i = 0; i < barCount; i++) {
      final double x = i * (barWidth + barGap);
      final double height = baseHeights[i];
      final double y = (size.height - height) / 2;

      final double activeProgressX = size.width * progress;
      final isActive = x <= activeProgressX;

      paint.color = isActive
          ? const Color(0xFFFFB534)
          : const Color(0xFFFFB534).withOpacity(0.18);

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, height),
        const Radius.circular(2),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant AudioWaveformPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isPlaying != isPlaying;
  }
}
