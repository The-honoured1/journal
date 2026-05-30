import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'sun_illustration.dart';
import 'cozy_moon_illustration.dart';

class DailyCheckinModal extends StatefulWidget {
  final bool isDark;
  final Function(
    double happy,
    double sad,
    double calm,
    double anxious,
    String feelingsText,
  ) onComplete;

  const DailyCheckinModal({
    super.key,
    required this.isDark,
    required this.onComplete,
  });

  @override
  State<DailyCheckinModal> createState() => _DailyCheckinModalState();
}

class _DailyCheckinModalState extends State<DailyCheckinModal> {
  final TextEditingController _feelingsController = TextEditingController();

  double happyVal = 0.5;
  double sadVal = 0.1;
  double calmVal = 0.5;
  double anxiousVal = 0.1;

  final Map<String, Color> _emotionColors = {
    'happy': const Color(0xFFD4A373), // Sunset Amber Gold
    'sad': const Color(0xFF8E9AAF), // Muted Blue Gray
    'calm': const Color(0xFF70A288), // Serene Forest Green
    'anxious': const Color(0xFFC5A3C1), // Serene Soft Lavender
  };

  @override
  void dispose() {
    _feelingsController.dispose();
    super.dispose();
  }

  bool _isDaytime() {
    final hour = DateTime.now().hour;
    return hour >= 6 && hour < 18;
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? const Color(0xFF0C100D) : const Color(0xFFF9F7F3);
    final cardBg = widget.isDark ? const Color(0xFF181F1B) : Colors.white;
    final primaryText = widget.isDark ? const Color(0xFFECEFEA) : const Color(0xFF1A1F1C);
    final secondaryText = widget.isDark ? const Color(0xFF8FA397) : const Color(0xFF5A625D);
    final accent = widget.isDark ? const Color(0xFF6A9978) : const Color(0xFF2C5E43);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(36),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Illustration Header
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: _isDaytime()
                        ? const SunIllustration()
                        : const CozyMoonIllustration(),
                  ),
                ).animate().scale(delay: 150.ms, duration: 400.ms, curve: Curves.easeOutBack),

                const SizedBox(height: 24),

                // Greeting & Title
                Text(
                  _isDaytime() ? "Rise & Shine" : "Cozy Evening",
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: accent,
                    letterSpacing: 2.0,
                  ),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 10),
                Text(
                  "How are you feeling today?",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: primaryText,
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 8),
                Text(
                  "A quick check-in to trace your path.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: secondaryText,
                  ),
                ).animate().fadeIn(delay: 450.ms),

                const SizedBox(height: 28),

                // Emotions Panel
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.01),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildEmotionSliderRow("Happy", CupertinoIcons.smiley, happyVal, _emotionColors['happy']!, (val) {
                        setState(() => happyVal = val);
                      }),
                      const Divider(height: 28),
                      _buildEmotionSliderRow("Sad", CupertinoIcons.sad_face, sadVal, _emotionColors['sad']!, (val) {
                        setState(() => sadVal = val);
                      }),
                      const Divider(height: 28),
                      _buildEmotionSliderRow("Calm", CupertinoIcons.wind, calmVal, _emotionColors['calm']!, (val) {
                        setState(() => calmVal = val);
                      }),
                      const Divider(height: 28),
                      _buildEmotionSliderRow("Anxious", CupertinoIcons.waveform, anxiousVal, _emotionColors['anxious']!, (val) {
                        setState(() => anxiousVal = val);
                      }),
                    ],
                  ),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.05, end: 0),

                const SizedBox(height: 24),

                // Mindset Input Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _feelingsController,
                    maxLines: 3,
                    style: GoogleFonts.outfit(color: primaryText, fontSize: 14, height: 1.5),
                    decoration: InputDecoration(
                      hintText: "What's on your mind? Express how you feel... (optional)",
                      hintStyle: GoogleFonts.outfit(color: secondaryText, fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: 28),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onComplete(happyVal, sadVal, calmVal, anxiousVal, _feelingsController.text);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Text(
                      "Complete Check-in",
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 650.ms).scale(duration: 300.ms, curve: Curves.easeOutBack),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmotionSliderRow(
    String label,
    IconData icon,
    double value,
    Color color,
    ValueChanged<double> onChanged,
  ) {
    final primaryText = widget.isDark ? const Color(0xFFECEFEA) : const Color(0xFF1A1F1C);
    final pct = (value * 100).toInt();

    return Row(
      children: [
        // Icon & Label
        SizedBox(
          width: 90,
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: primaryText,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Slider
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 6,
              activeTrackColor: color,
              inactiveTrackColor: color.withOpacity(0.12),
              thumbColor: color,
              overlayColor: color.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: value,
              min: 0.0,
              max: 1.0,
              onChanged: onChanged,
            ),
          ),
        ),
        // Value label
        SizedBox(
          width: 38,
          child: Text(
            "$pct%",
            textAlign: TextAlign.right,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
