// lib/screens/analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final backgroundColor = isDark ? const Color(0xFF1E1A1A) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'Analytics',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // High-level score and subtitle
            Center(
              child: Column(
                children: [
                  Text(
                    "$activeScore",
                    style: TextStyle(
                      fontSize: 68,
                      fontWeight: FontWeight.w600,
                      color: primaryText,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Celebrate what made you smile today.",
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
            // Emotions Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Emotions",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Here are four core emotions for your journal",
                    style: TextStyle(
                      fontSize: 13,
                      color: secondaryText,
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Vertical pill-shaped bars
                  SizedBox(
                    height: 220,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildVerticalBar(
                          label: "Happy",
                          value: happy,
                          color: const Color(0xFFFBB540),
                          isDark: isDark,
                        ),
                        _buildVerticalBar(
                          label: "Sad",
                          value: sad,
                          color: const Color(0xFF784136),
                          isDark: isDark,
                        ),
                        _buildVerticalBar(
                          label: "Calm",
                          value: calm,
                          color: const Color(0xFF839B3D),
                          isDark: isDark,
                        ),
                        _buildVerticalBar(
                          label: "Anxious",
                          value: anxious,
                          color: const Color(0xFF706E66),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            // CTA button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onCreateNew,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFBB540),
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
    final barHeight = 130.0 * value; // Max height mapping

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 50,
          height: 165,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1C1A) : const Color(0xFFEFECE6),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutBack,
                width: 50,
                height: barHeight + 35, // Base height buffer for rounded top/bottom capsule look
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
                        color: color == const Color(0xFFFBB540)
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
