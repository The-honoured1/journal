import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/journal_entry.dart';

class DashboardScreen extends StatefulWidget {
  final bool isDark;
  final Color primaryText;
  final Color secondaryText;
  final Color cardBg;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelect;
  final Function(JournalEntry) onOpenJournal;
  final List<JournalEntry> journalEntries;
  final String? todayMood;
  final VoidCallback? onCheckIn;

  const DashboardScreen({
    super.key,
    required this.isDark,
    required this.primaryText,
    required this.secondaryText,
    required this.cardBg,
    required this.selectedDate,
    required this.onDateSelect,
    required this.onOpenJournal,
    required this.journalEntries,
    this.todayMood,
    this.onCheckIn,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(widget.selectedDate.year, widget.selectedDate.month);
  }

  // Parses entries' dates (e.g. "March 22, 2025") into DateTime
  DateTime? _parseEntryDate(String dateStr) {
    try {
      final parts = dateStr.replaceAll(',', '').split(' ');
      if (parts.length != 3) return null;
      final monthStr = parts[0].toLowerCase();
      final day = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day == null || year == null) return null;

      final months = [
        'january', 'february', 'march', 'april', 'may', 'june',
        'july', 'august', 'september', 'october', 'november', 'december'
      ];
      final month = months.indexOf(monthStr) + 1;
      if (month == 0) return null;

      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  String _formatDateString(DateTime dt) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return "${months[dt.month - 1]} ${dt.day}, ${dt.year}";
  }

  List<DateTime?> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final startOffset = firstDay.weekday - 1; // Mon = 0, Sun = 6

    final List<DateTime?> cells = [];
    for (int i = 0; i < startOffset; i++) {
      cells.add(null);
    }
    for (int i = 1; i <= daysInMonth; i++) {
      cells.add(DateTime(month.year, month.month, i));
    }
    return cells;
  }

  // Get a flashback entry if there is a past memory (exactly 7 days ago, 30 days ago, or just oldest)
  JournalEntry? _getFlashbackEntry() {
    if (widget.journalEntries.isEmpty) return null;
    final now = DateTime.now();
    
    // Look for entries in the past
    final pastEntries = widget.journalEntries.where((e) {
      final dt = _parseEntryDate(e.date);
      return dt != null && dt.isBefore(DateTime(now.year, now.month, now.day));
    }).toList();

    if (pastEntries.isEmpty) return null;
    
    // Find if any entry matches exactly 7 or 30 days ago
    for (final entry in pastEntries) {
      final dt = _parseEntryDate(entry.date)!;
      final diff = DateTime(now.year, now.month, now.day).difference(dt).inDays;
      if (diff == 7 || diff == 30 || diff == 365) {
        return entry;
      }
    }
    
    // Otherwise fallback to the oldest entry to showcase memory lane
    pastEntries.sort((a, b) {
      final da = _parseEntryDate(a.date) ?? DateTime.now();
      final db = _parseEntryDate(b.date) ?? DateTime.now();
      return da.compareTo(db);
    });
    
    return pastEntries.first;
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.isDark ? const Color(0xFF0E0C1A) : const Color(0xFFF5F0E8);
    final accentColor = widget.isDark ? const Color(0xFF9B7FE8) : const Color(0xFF3D2B8E);
    final accentAmber = widget.isDark ? const Color(0xFFF0A057) : const Color(0xFFE07B3C);

    final selectedDateStr = _formatDateString(widget.selectedDate);
    final dailyEntries = widget.journalEntries.where((e) => e.date == selectedDateStr).toList();
    final flashback = _getFlashbackEntry();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // ── How do you feel + 7-day strip ───────────────────────────
              _buildMoodHero(accentColor, accentAmber),

              const SizedBox(height: 28),

              // ── Calendar ─────────────────────────────────────────────────
              _buildCalendarCard(accentColor),

              const SizedBox(height: 36),

              // ── Memory Lane ──────────────────────────────────────────────
              if (flashback != null) ...[
                _buildSectionHeader("Memory Lane"),
                const SizedBox(height: 14),
                _buildFlashbackCard(flashback),
                const SizedBox(height: 36),
              ],

              // ── Daily reflections ─────────────────────────────────────────
              _buildSectionHeader("Reflections on $selectedDateStr"),
              const SizedBox(height: 14),

              if (dailyEntries.isEmpty)
                _buildEmptyState()
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: dailyEntries.length,
                  itemBuilder: (context, idx) {
                    return _buildEntryCard(dailyEntries[idx], accentColor);
                  },
                ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  // ── Mood hero card ────────────────────────────────────────────────────────
  Widget _buildMoodHero(Color accent, Color amber) {
    final isDark = widget.isDark;
    final now = DateTime.now();
    final todayMood = widget.todayMood;
    final hasMood = todayMood != null;

    // 7-day strip
    final days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "How do you feel?" hero
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(26, 28, 26, 24),
          decoration: BoxDecoration(
            color: widget.cardBg,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark ? const Color(0xFF2E2A4A) : const Color(0xFFE8DFD0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 7-day mini strip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: days.map((day) {
                  final isToday = day.day == now.day &&
                      day.month == now.month &&
                      day.year == now.year;
                  final isSelected = widget.selectedDate.day == day.day &&
                      widget.selectedDate.month == day.month &&
                      widget.selectedDate.year == day.year;
                  final dateStr = _formatDateString(day);
                  final hasEntry =
                      widget.journalEntries.any((e) => e.date == dateStr);
                  final label = dayLabels[(day.weekday - 1) % 7];

                  return GestureDetector(
                    onTap: () => widget.onDateSelect(day),
                    child: Column(
                      children: [
                        Text(
                          label,
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? accent : widget.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 6),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? accent
                                : isDark
                                    ? const Color(0xFF2A2445)
                                    : const Color(0xFFF0EBF8),
                            shape: BoxShape.circle,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(
                                '${day.day}',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: isToday
                                      ? FontWeight.w800
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : widget.primaryText,
                                ),
                              ),
                              if (hasEntry && !isSelected)
                                Positioned(
                                  bottom: 4,
                                  child: Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: accent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),

              // Headline
              Text(
                hasMood
                    ? 'You felt $todayMood today.'
                    : 'How do you feel?',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: widget.primaryText,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 18),

              // Check-in button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: widget.onCheckIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? const Color(0xFF1A1628)
                        : const Color(0xFF1A1628),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    hasMood ? 'update check-in' : 'check in',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: widget.secondaryText,
          letterSpacing: 1.4,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 32),
      decoration: BoxDecoration(
        color: widget.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.isDark ? const Color(0xFF2E2A4A) : const Color(0xFFE8DFD0),
        ),
      ),
      child: Column(
        children: [
          Icon(CupertinoIcons.square_pencil, size: 40, color: widget.secondaryText.withOpacity(0.35)),
          const SizedBox(height: 20),
          Text(
            "No reflections yet",
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: widget.primaryText,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap + below to start writing.",
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(color: widget.secondaryText, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard(Color accentColor) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final cells = _getDaysInMonth(_focusedMonth);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.isDark ? const Color(0xFF2E2A4A) : const Color(0xFFE8DFD0),
        ),
      ),
      child: Column(
        children: [
          // Month navigation header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: widget.primaryText),
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
                  });
                },
              ),
              Text(
                "${months[_focusedMonth.month - 1]} ${_focusedMonth.year}",
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.primaryText,
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: widget.primaryText),
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          
          // Days of Week labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
              return SizedBox(
                width: 36,
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: widget.secondaryText,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          
          // Days Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cells.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemBuilder: (context, idx) {
              final cellDate = cells[idx];
              if (cellDate == null) {
                return const SizedBox.shrink();
              }
              
              final isSelected = widget.selectedDate.year == cellDate.year &&
                  widget.selectedDate.month == cellDate.month &&
                  widget.selectedDate.day == cellDate.day;
                  
              final cellDateStr = _formatDateString(cellDate);
              final hasEntries = widget.journalEntries.any((e) => e.date == cellDateStr);

              return GestureDetector(
                onTap: () => widget.onDateSelect(cellDate),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? accentColor
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: Text(
                          cellDate.day.toString(),
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? Colors.white
                                : widget.primaryText,
                          ),
                        ),
                      ),
                      if (hasEntries)
                        Positioned(
                          bottom: 5,
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : accentColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFlashbackCard(JournalEntry entry) {
    final entryDate = _parseEntryDate(entry.date);
    String flashbackTitle = "On this day in the past...";
    if (entryDate != null) {
      final diff = DateTime.now().difference(entryDate).inDays;
      if (diff >= 365) {
        final yrs = (diff / 365).floor();
        flashbackTitle = yrs == 1 ? "1 Year Ago Today" : "$yrs Years Ago Today";
      } else if (diff >= 30) {
        final mths = (diff / 30).floor();
        flashbackTitle = mths == 1 ? "1 Month Ago" : "$mths Months Ago";
      } else if (diff >= 7) {
        final wks = (diff / 7).floor();
        flashbackTitle = wks == 1 ? "1 Week Ago" : "$wks Weeks Ago";
      }
    }

    final hasImage = entry.imageUrls.isNotEmpty;
    final bgImg = hasImage ? entry.imageUrls.first : "https://images.unsplash.com/photo-1502082553048-f009c37129b9?w=500&auto=format&fit=crop&q=80";

    return GestureDetector(
      onTap: () => widget.onOpenJournal(entry),
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          image: DecorationImage(
            image: NetworkImage(bgImg),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.85),
                Colors.black.withOpacity(0.3),
                Colors.transparent,
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                flashbackTitle.toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFF0A057),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                entry.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                entry.text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEntryCard(JournalEntry entry, Color accentColor) {
    final hasImage = entry.imageUrls.isNotEmpty;
    final hasAudio = entry.voiceNotePath != null;
    final hasFiles = entry.fileNames.isNotEmpty;

    return GestureDetector(
      onTap: () => widget.onOpenJournal(entry),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: widget.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.isDark ? const Color(0xFF2E2A4A) : const Color(0xFFE8DFD0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Category Tag
                if (entry.categories.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      entry.categories.first,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                  ),
                const Spacer(),
                // Mood label
                Text(
                  "${entry.mood} mood",
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: widget.secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Text details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: widget.primaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        entry.text,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: widget.secondaryText,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasImage) ...[
                  const SizedBox(width: 16),
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: NetworkImage(entry.imageUrls.first),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            
            // File & Audio info row
            if (hasAudio || hasFiles) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (hasAudio) ...[
                    Icon(CupertinoIcons.mic_fill, size: 14, color: accentColor),
                    const SizedBox(width: 6),
                    Text(
                      "Audio Note (${entry.voiceDurationSec}s)",
                      style: GoogleFonts.outfit(fontSize: 12, color: widget.secondaryText, fontWeight: FontWeight.w500),
                    ),
                    if (hasFiles) const SizedBox(width: 20),
                  ],
                  if (hasFiles) ...[
                    Icon(CupertinoIcons.paperclip, size: 14, color: widget.secondaryText),
                    const SizedBox(width: 6),
                    Text(
                      "${entry.fileNames.length} file(s)",
                      style: GoogleFonts.outfit(fontSize: 12, color: widget.secondaryText, fontWeight: FontWeight.w500),
                    ),
                  ],
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}
