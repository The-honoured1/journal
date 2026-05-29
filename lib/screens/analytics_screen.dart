import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  final bool isDark;
  final Color primaryText;
  final Color secondaryText;
  final Color cardBg;
  final int activeScore;
  final double happy;
  final double sad;
  final double calm;
  final double anxious;
  final VoidCallback onCreateNew;

  const AnalyticsScreen({
    super.key,
    required this.isDark,
    required this.primaryText,
    required this.secondaryText,
    required this.cardBg,
    required this.activeScore,
    required this.happy,
    required this.sad,
    required this.calm,
    required this.anxious,
    required this.onCreateNew,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Center(
              child: Column(
                children: [
                  Text(
                    "$activeScore",
                    style: TextStyle(
                      fontSize: 68,
                      fontFamily: 'serif',
                      fontWeight: FontWeight.w900,
                      color: primaryText,
                      letterSpacing: -2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Mindfulness points collected",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Emotions Breakdown",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "These are your four core logged feelings.",
                    style: TextStyle(
                      fontSize: 12,
                      color: secondaryText,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 220,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildVerticalBar(
                          label: "Happy",
                          value: happy,
                          color: const Color(0xFFFFB534),
                          isDark: isDark,
                        ),
                        _buildVerticalBar(
                          label: "Sad",
                          value: sad,
                          color: const Color(0xFF78473B),
                          isDark: isDark,
                        ),
                        _buildVerticalBar(
                          label: "Calm",
                          value: calm,
                          color: const Color(0xFF8BA64F),
                          isDark: isDark,
                        ),
                        _buildVerticalBar(
                          label: "Anxious",
                          value: anxious,
                          color: const Color(0xFF7A7C75),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onCreateNew,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB534),
                  foregroundColor: const Color(0xFF2C2A29),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  "Create a New Journal",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalBar({
    required String label,
    required double value,
    required Color color,
    required bool isDark,
  }) {
    final pct = (value * 100).toInt();
    final barHeight = 160.0 * value;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 50,
          height: 165,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1C1A) : const Color(0xFFF7F5F2),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutBack,
                width: 50,
                height: barHeight + 35,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      "$pct%",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color == const Color(0xFFFFB534)
                            ? const Color(0xFF2C2A29)
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
      ],
    );
  }
}
