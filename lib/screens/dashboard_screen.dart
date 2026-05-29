import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/journal_entry.dart';
import '../widgets/sun_illustration.dart';
import '../widgets/cozy_moon_illustration.dart';

class DashboardScreen extends StatefulWidget {
  final bool isDark;
  final Color primaryText;
  final Color secondaryText;
  final Color cardBg;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelect;
  final Function(JournalEntry) onOpenJournal;
  final List<JournalEntry> journalEntries;

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
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DateTime _focusedMonth;
  bool _isMonthView = true;

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
    final backgroundColor = widget.isDark ? const Color(0xFF1E1A1A) : Colors.white;
    final accentColor = const Color(0xFFFFB534);

    final selectedDateStr = _formatDateString(widget.selectedDate);
    final dailyEntries = widget.journalEntries.where((e) => e.date == selectedDateStr).toList();
    final flashback = _getFlashbackEntry();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'Journal',
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: widget.primaryText,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              
              // Custom interactive Month Calendar view
              _buildCalendarCard(accentColor),
              
              const SizedBox(height: 24),
              
              // Flashback (Google Photos Style) Memory lane card
              if (flashback != null) ...[
                _buildSectionHeader("Memory Lane ✨"),
                const SizedBox(height: 12),
                _buildFlashbackCard(flashback),
                const SizedBox(height: 24),
              ],
              
              // Daily reflections header
              _buildSectionHeader("Reflections on $selectedDateStr"),
              const SizedBox(height: 12),
              
              // Reflections list
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
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: widget.primaryText,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: widget.cardBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(CupertinoIcons.square_pencil, size: 40, color: widget.secondaryText.withOpacity(0.5)),
          const SizedBox(height: 12),
          Text(
            "No reflections recorded for this day.",
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: widget.secondaryText,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap + below to start writing your diary.",
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: widget.secondaryText.withOpacity(0.7),
              fontSize: 12,
            ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.cardBg,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
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
                  fontSize: 17,
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
          const SizedBox(height: 10),
          
          // Days of Week labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
              return SizedBox(
                width: 32,
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: widget.secondaryText,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          
          // Days Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cells.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
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
                                ? const Color(0xFF2C2A29)
                                : widget.primaryText,
                          ),
                        ),
                      ),
                      if (hasEntries)
                        Positioned(
                          bottom: 4,
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF2C2A29) : accentColor,
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
        flashbackTitle = yrs == 1 ? "1 Year Ago today... 🍃" : "$yrs Years Ago today... 🍃";
      } else if (diff >= 30) {
        final mths = (diff / 30).floor();
        flashbackTitle = mths == 1 ? "1 Month Ago... ✨" : "$mths Months Ago... ✨";
      } else if (diff >= 7) {
        final wks = (diff / 7).floor();
        flashbackTitle = wks == 1 ? "1 Week Ago... 🌿" : "$wks Weeks Ago... 🌿";
      }
    }

    final hasImage = entry.imageUrls.isNotEmpty;
    final bgImg = hasImage ? entry.imageUrls.first : "https://images.unsplash.com/photo-1502082553048-f009c37129b9?w=500&auto=format&fit=crop&q=80";

    return GestureDetector(
      onTap: () => widget.onOpenJournal(entry),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          image: DecorationImage(
            image: NetworkImage(bgImg),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
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
                Colors.black.withOpacity(0.4),
                Colors.transparent,
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                flashbackTitle,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFB534),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                entry.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                entry.text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.8),
                  height: 1.3,
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
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.cardBg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Category Tag
                if (entry.categories.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.15),
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
                // Mood icon label
                Text(
                  "${entry.mood} mood",
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: widget.secondaryText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
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
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: widget.primaryText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        entry.text,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: widget.secondaryText,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasImage) ...[
                  const SizedBox(width: 12),
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
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
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (hasAudio) ...[
                    const Icon(CupertinoIcons.mic_fill, size: 14, color: Color(0xFFFFB534)),
                    const SizedBox(width: 4),
                    Text(
                      "Audio Note (${entry.voiceDurationSec}s)",
                      style: GoogleFonts.outfit(fontSize: 11, color: widget.secondaryText),
                    ),
                    if (hasFiles) const SizedBox(width: 16),
                  ],
                  if (hasFiles) ...[
                    Icon(CupertinoIcons.paperclip, size: 14, color: widget.secondaryText),
                    const SizedBox(width: 4),
                    Text(
                      "${entry.fileNames.length} file(s)",
                      style: GoogleFonts.outfit(fontSize: 11, color: widget.secondaryText),
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
