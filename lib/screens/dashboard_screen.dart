import 'package:flutter/material.dart';
import '../widgets/sun_illustration.dart';
import '../widgets/cozy_moon_illustration.dart';

class DashboardScreen extends StatefulWidget {
  final bool isDark;
  final Color primaryText;
  final Color secondaryText;
  final Color cardBg;
  final int selectedDayIndex;
  final ValueChanged<int> onDaySelect;
  final VoidCallback onOpenJournal;
  final List<Map<String, dynamic>> journalEntries;

  const DashboardScreen({
    super.key,
    required this.isDark,
    required this.primaryText,
    required this.secondaryText,
    required this.cardBg,
    required this.selectedDayIndex,
    required this.onDaySelect,
    required this.onOpenJournal,
    required this.journalEntries,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.85);

  final List<Map<String, String>> calendarDays = [
    {"day": "Mon", "num": "7"},
    {"day": "Tue", "num": "8"},
    {"day": "Wed", "num": "9"},
    {"day": "Thu", "num": "10"},
    {"day": "Fri", "num": "11"},
    {"day": "Sat", "num": "12"},
    {"day": "Sun", "num": "13"},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(calendarDays.length, (index) {
                final isSelected = widget.selectedDayIndex == index;
                final dayColor = isSelected
                    ? const Color(0xFFFFB534)
                    : (widget.isDark ? const Color(0xFF282522) : Colors.white);
                final textColor = isSelected
                    ? const Color(0xFF2C2A29)
                    : widget.primaryText;

                return GestureDetector(
                  onTap: () => widget.onDaySelect(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
                    decoration: BoxDecoration(
                      color: dayColor,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFFFFB534).withOpacity(0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              )
                            ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          calendarDays[index]["day"]!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? const Color(0xFF2C2A29).withOpacity(0.7) : widget.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          calendarDays[index]["num"]!,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "My Journal",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.primaryText,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "See all",
                    style: TextStyle(
                      color: Color(0xFFFFB534),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 220,
            child: PageView(
              controller: _pageController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                GestureDetector(
                  onTap: widget.onOpenJournal,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 14.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCECD0),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Stack(
                          children: [
                            const Positioned.fill(
                              child: SunIllustration(),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      "Morning Journal",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF785213),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    "Let’s start your day",
                                    style: TextStyle(
                                      fontFamily: 'serif',
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C2A29),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    "Begin with a mindful morning\nreflections and intentions.",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF63564A),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 14.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6CEE5),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Stack(
                        children: [
                          const Positioned.fill(
                            child: CozyMoonIllustration(),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    "Evening Reflection",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF332049),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "Pause & Unwind",
                                  style: TextStyle(
                                    fontFamily: 'serif',
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  "Celebrate small joys and release\nthe tensions of today.",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFFECE7FF),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Quick Journal",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.primaryText,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "See all",
                    style: TextStyle(
                      color: Color(0xFFFFB534),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 155,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              children: [
                _buildQuickJournalCard(
                  title: "Pause & reflect 🌿",
                  desc: "What are you grateful for today?",
                  cardColor: widget.isDark ? const Color(0xFF422C2A) : const Color(0xFFFFECE8),
                  tagText1: "Today",
                  tagText2: "Personal",
                  tagBg1: widget.isDark ? Colors.black26 : Colors.white60,
                  tagBg2: widget.isDark ? const Color(0xFF78473B).withOpacity(0.3) : const Color(0xFFFFD4CD),
                  tagColor1: widget.primaryText.withOpacity(0.8),
                  tagColor2: const Color(0xFF78473B),
                ),
                const SizedBox(width: 14),
                _buildQuickJournalCard(
                  title: "Set Intentions 😐",
                  desc: "How do you want to feel today?",
                  cardColor: widget.isDark ? const Color(0xFF2C2A44) : const Color(0xFFE8E5FF),
                  tagText1: "Today",
                  tagText2: "Family",
                  tagBg1: widget.isDark ? Colors.black26 : Colors.white60,
                  tagBg2: widget.isDark ? const Color(0xFF4C458A).withOpacity(0.3) : const Color(0xFFD4CFFF),
                  tagColor1: widget.primaryText.withOpacity(0.8),
                  tagColor2: const Color(0xFF4C458A),
                ),
                const SizedBox(width: 14),
                _buildQuickJournalCard(
                  title: "Gratitude Check ✨",
                  desc: "Name three things that bring peace.",
                  cardColor: widget.isDark ? const Color(0xFF253320) : const Color(0xFFE2F0D9),
                  tagText1: "Daily",
                  tagText2: "Mindful",
                  tagBg1: widget.isDark ? Colors.black26 : Colors.white60,
                  tagBg2: widget.isDark ? const Color(0xFF3B5D34).withOpacity(0.3) : const Color(0xFFC7E5BB),
                  tagColor1: widget.primaryText.withOpacity(0.8),
                  tagColor2: const Color(0xFF3B5D34),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildQuickJournalCard({
    required String title,
    required String desc,
    required Color cardColor,
    required String tagText1,
    required String tagText2,
    required Color tagBg1,
    required Color tagBg2,
    required Color tagColor1,
    required Color tagColor2,
  }) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C2A29),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                desc,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF5C5A58),
                  height: 1.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: tagBg1,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tagText1,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: tagColor1,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: tagBg2,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tagText2,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: tagColor2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
