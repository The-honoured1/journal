import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/sun_illustration.dart';
import '../widgets/cozy_moon_illustration.dart';

// Helper to get serif font style
TextStyle getSerifStyle({double? fontSize, FontWeight? fontWeight, Color? color}) {
  return TextStyle(
    fontFamily: 'serif',
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
  );
}

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
  final PageController _pageController = PageController(viewportFraction: 0.80);

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
    // Use theme colors for background based on dark mode
    final backgroundColor = widget.isDark ? const Color(0xFF1E1A1A) : Colors.white;
    final textColor = widget.isDark ? Colors.white70 : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'Dashboard',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: widget.primaryText,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(widget.isDark ? Icons.wb_sunny : Icons.nightlight_round),
            color: widget.primaryText,
            onPressed: () {
              // Toggle theme callback could be added later
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Horizontal calendar row
              _buildCalendarRow(),
              const SizedBox(height: 24),
              // My Journal Section Header
              _buildSectionHeader('My Journal'),
              const SizedBox(height: 12),
              // Swiping Horizontal Journal Cards
              _buildJournalCards(),
              const SizedBox(height: 24),
              // Quick Journal section
              _buildSectionHeader('Quick Journal'),
              const SizedBox(height: 12),
              _buildQuickJournalCards(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Calendar row builder for cleaner structure
  Widget _buildCalendarRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(calendarDays.length, (index) {
        final isSelected = widget.selectedDayIndex == index;
        final dayName = calendarDays[index]["day"]!;
        final dayNum = calendarDays[index]["num"]!;
        return GestureDetector(
          onTap: () => widget.onDaySelect(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 80,
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFFBB540)
                  : (widget.isDark ? const Color(0xFF282522) : Colors.white),
              borderRadius: BorderRadius.circular(22),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFBB540).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      )
                    ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dayName,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF2C2A29)
                        : (widget.isDark ? const Color(0xFF9E9992) : const Color(0xFF7C7975)),
                  ),
                ),
                Text(
                  dayNum,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? const Color(0xFF2C2A29)
                        : (widget.isDark ? Colors.white : const Color(0xFF2C2A29)),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // Section header builder to keep consistency
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: widget.primaryText,
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              'See all',
              style: TextStyle(
                color: Color(0xFF7C7975),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Horizontal journal cards with refined styling
  Widget _buildJournalCards() {
    return SizedBox(
      height: 220,
      child: PageView(
        controller: _pageController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          // Morning Card
          GestureDetector(
            onTap: widget.onOpenJournal,
            child: Padding(
              padding: const EdgeInsets.only(right: 14.0),
              child: _styledJournalCard(
                backgroundColor: const Color(0xFFFCECD0),
                illustration: const SunIllustration(),
                title: "Let’s start your day",
                description: "Begin with a mindful morning\nreflections.",
                titleStyle: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C2A29),
                ),
                descStyle: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF63564A),
                  height: 1.4,
                ),
              ),
            ),
          ),
          // Evening Card
          Padding(
            padding: const EdgeInsets.only(right: 14.0),
            child: _styledJournalCard(
              backgroundColor: widget.isDark ? const Color(0xFF2E2A26) : const Color(0xFFD6CEBF),
              illustration: const CozyMoonIllustration(),
              verticalLabel: 'Evening',
              title: "Evening Reflection",
              description: "Celebrate small joys and release\nthe tensions of today.",
              titleStyle: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              descStyle: const TextStyle(
                fontSize: 13,
                color: Color(0xFFECE7FF),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build a styled journal card, optional vertical label for evening card
  Widget _styledJournalCard({
    required Color backgroundColor,
    required Widget illustration,
    String? verticalLabel,
    required String title,
    required String description,
    required TextStyle titleStyle,
    required TextStyle descStyle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
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
            Positioned.fill(child: illustration),
            if (verticalLabel != null)
              Positioned(
                left: 12,
                top: 0,
                bottom: 0,
                child: Center(
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Text(
                      verticalLabel,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.isDark ? Colors.white60 : const Color(0xFF4C473E),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(title, style: titleStyle),
                  const SizedBox(height: 6),
                  Text(description, style: descStyle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Quick Journal cards list
  Widget _buildQuickJournalCards() {
    return SizedBox(
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
            desc: "How do you want to feel?",
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
      width: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildTag(tagText1, tagBg1, tagColor1),
              const SizedBox(width: 8),
              _buildTag(tagText2, tagBg2, tagColor2),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: widget.primaryText)),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
