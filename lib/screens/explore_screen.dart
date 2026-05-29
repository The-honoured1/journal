import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ExploreScreen extends StatelessWidget {
  final bool isDark;
  final Color primaryText;
  final Color secondaryText;
  final Color cardBg;

  const ExploreScreen({
    super.key,
    required this.isDark,
    required this.primaryText,
    required this.secondaryText,
    required this.cardBg,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF332F2A) : const Color(0xFFFFF7EA),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: const Color(0xFFFFB534).withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB534).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "Guided Session",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFB534),
                        ),
                      ),
                    ),
                    const Icon(CupertinoIcons.headphones, color: Color(0xFFFFB534), size: 18),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "Calming the Busy Mind",
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "A 10-minute quiet soundscape built to help you disconnect from structural cognitive loads.",
                  style: TextStyle(
                    fontSize: 13,
                    color: secondaryText,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(CupertinoIcons.play_fill, size: 12, color: Color(0xFF2C2A29)),
                  label: const Text(
                    "Listen Now",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2C2A29)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB534),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Weekly Readings",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryText,
            ),
          ),
          const SizedBox(height: 12),
          _buildExploreItem(
            title: "Embracing Imperfection",
            duration: "5 mins read",
            category: "Self-Love",
          ),
          _buildExploreItem(
            title: "Why Writing By Hand Calms Us",
            duration: "8 mins read",
            category: "Science",
          ),
        ],
      ),
    );
  }

  Widget _buildExploreItem({
    required String title,
    required String duration,
    required String category,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFB534),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  duration,
                  style: TextStyle(
                    fontSize: 11,
                    color: secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFFB534).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.right_chevron,
              size: 14,
              color: Color(0xFFFFB534),
            ),
          ),
        ],
      ),
    );
  }
}
