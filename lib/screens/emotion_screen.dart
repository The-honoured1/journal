import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/journal_entry.dart';

class EmotionScreen extends StatefulWidget {
  final bool isDark;
  final Color primaryText;
  final Color secondaryText;
  final Color cardBg;
  final List<JournalEntry> journalEntries;

  const EmotionScreen({
    super.key,
    required this.isDark,
    required this.primaryText,
    required this.secondaryText,
    required this.cardBg,
    required this.journalEntries,
  });

  @override
  State<EmotionScreen> createState() => _EmotionScreenState();
}

class _EmotionScreenState extends State<EmotionScreen>
    with SingleTickerProviderStateMixin {
  // 0 = Week, 1 = Month, 2 = Year
  int _viewMode = 1;
  late DateTime _focusedMonth;
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _tabCtrl = TabController(length: 3, vsync: this, initialIndex: 1);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        setState(() => _viewMode = _tabCtrl.index);
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  // ── helpers ────────────────────────────────────────────────────────────────

  DateTime? _parseDate(String raw) {
    try {
      const months = {
        'January': 1, 'February': 2, 'March': 3, 'April': 4,
        'May': 5, 'June': 6, 'July': 7, 'August': 8,
        'September': 9, 'October': 10, 'November': 11, 'December': 12,
      };
      final parts = raw.replaceAll(',', '').split(' ');
      if (parts.length == 3) {
        final m = months[parts[0]] ?? 1;
        final d = int.tryParse(parts[1]) ?? 1;
        final y = int.tryParse(parts[2]) ?? 2024;
        return DateTime(y, m, d);
      }
    } catch (_) {}
    return null;
  }

  static Color moodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':   return const Color(0xFFFFB347);
      case 'sad':     return const Color(0xFF6EB5FF);
      case 'anxious': return const Color(0xFFFF7F7F);
      case 'calm':    return const Color(0xFF7FE8C2);
      default:        return const Color(0xFF9B7FE8);
    }
  }

  static IconData moodIcon(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':   return CupertinoIcons.sun_max_fill;
      case 'sad':     return CupertinoIcons.cloud_rain_fill;
      case 'anxious': return CupertinoIcons.bolt_fill;
      case 'calm':    return CupertinoIcons.leaf_arrow_circlepath;
      default:        return CupertinoIcons.moon_stars_fill;
    }
  }

  /// Get mood for a given day (most frequent, or last entry's mood)
  String? _moodForDay(DateTime day) {
    final entries = widget.journalEntries.where((e) {
      final d = _parseDate(e.date);
      return d != null &&
          d.year == day.year &&
          d.month == day.month &&
          d.day == day.day;
    }).toList();
    if (entries.isEmpty) return null;
    // pick dominant mood
    final counts = <String, int>{};
    for (final e in entries) {
      counts[e.mood] = (counts[e.mood] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  Map<String, int> _moodDistribution() {
    final map = <String, int>{};
    for (final e in widget.journalEntries) {
      map[e.mood] = (map[e.mood] ?? 0) + 1;
    }
    return map;
  }

  // average mood score (happy - anxious/sad weighted)
  double _averageMoodScore() {
    if (widget.journalEntries.isEmpty) return 0.5;
    double sum = 0;
    for (final e in widget.journalEntries) {
      sum += (e.happyVal + e.calmVal - e.sadVal - e.anxiousVal + 2) / 4;
    }
    return (sum / widget.journalEntries.length).clamp(0.0, 1.0);
  }

  List<DateTime?> _daysInMonth(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final count = DateTime(month.year, month.month + 1, 0).day;
    final offset = first.weekday - 1;
    return [
      ...List<DateTime?>.filled(offset, null),
      ...List.generate(count, (i) => DateTime(month.year, month.month, i + 1)),
    ];
  }

  List<DateTime> _daysThisWeek() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final bg = isDark ? const Color(0xFF0E0C1A) : const Color(0xFFF5F0E8);
    final accent = isDark ? const Color(0xFF9B7FE8) : const Color(0xFF3D2B8E);
    final border = isDark ? const Color(0xFF2E2A4A) : const Color(0xFFE8DFD0);
    final tabInactive = isDark ? const Color(0xFF2A2445) : const Color(0xFFEDE8FF);

    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];

    return Container(
      color: bg,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // ── Week / Month / Year tab toggle ────────────────────────────
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: tabInactive,
                borderRadius: BorderRadius.circular(22),
              ),
              child: TabBar(
                controller: _tabCtrl,
                indicator: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelStyle: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: widget.secondaryText,
                padding: const EdgeInsets.all(4),
                tabs: const [
                  Tab(text: 'Week'),
                  Tab(text: 'Month'),
                  Tab(text: 'Year'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Month navigator (only for Month/Year view) ────────────────
            if (_viewMode >= 1)
              Row(
                children: [
                  IconButton(
                    onPressed: () => setState(() {
                      _focusedMonth =
                          DateTime(_focusedMonth.year, _focusedMonth.month - 1);
                    }),
                    icon: Icon(Icons.chevron_left, color: widget.primaryText),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  Text(
                    _viewMode == 2
                        ? '${_focusedMonth.year}'
                        : '${monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: widget.primaryText,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() {
                      _focusedMonth =
                          DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                    }),
                    icon: Icon(Icons.chevron_right, color: widget.primaryText),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),

            const SizedBox(height: 16),

            // ── Average Mood card ─────────────────────────────────────────
            _buildAverageMoodCard(accent, border),

            const SizedBox(height: 24),

            // ── Mood calendar grid ────────────────────────────────────────
            _buildMoodCalendarCard(accent, border),

            const SizedBox(height: 24),

            // ── Mood Distribution card ────────────────────────────────────
            _buildDistributionCard(border),

            const SizedBox(height: 24),

            // ── Recent entries streak ─────────────────────────────────────
            _buildStreakCard(accent, border),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // ── Average Mood ──────────────────────────────────────────────────────────

  Widget _buildAverageMoodCard(Color accent, Color border) {
    final score = _averageMoodScore();
    final pct = (score * 100).round();
    String label;
    Color col;
    if (score >= 0.75) { label = 'Great'; col = const Color(0xFF7FE8C2); }
    else if (score >= 0.55) { label = 'Good'; col = const Color(0xFFFFB347); }
    else if (score >= 0.40) { label = 'Okay'; col = const Color(0xFF9B7FE8); }
    else if (score >= 0.25) { label = 'Low'; col = const Color(0xFF6EB5FF); }
    else { label = 'Rough'; col = const Color(0xFFFF7F7F); }

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: widget.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Average Mood',
            style: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: widget.primaryText,
            ),
          ),
          Text(
            'Your average mood by day',
            style: GoogleFonts.outfit(fontSize: 13, color: widget.secondaryText),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Score ring
              SizedBox(
                width: 80,
                height: 80,
                child: CustomPaint(
                  painter: _RingPainter(score: score, color: col),
                  child: Center(
                    child: Text(
                      '$pct%',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: widget.primaryText,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: col,
                    ),
                  ),
                  Text(
                    'Based on ${widget.journalEntries.length} entries',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: widget.secondaryText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Mood calendar ─────────────────────────────────────────────────────────

  Widget _buildMoodCalendarCard(Color accent, Color border) {
    final List<DateTime> days;
    if (_viewMode == 0) {
      days = _daysThisWeek();
    } else {
      days = _daysInMonth(_focusedMonth)
          .where((d) => d != null)
          .cast<DateTime>()
          .toList();
    }

    final weekDayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: widget.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mood Calendar',
            style: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: widget.primaryText,
            ),
          ),
          Text(
            'Each dot shows your mood that day',
            style: GoogleFonts.outfit(fontSize: 13, color: widget.secondaryText),
          ),
          const SizedBox(height: 18),

          // Day-of-week header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDayLabels
                .map((l) => SizedBox(
                      width: 34,
                      child: Text(
                        l,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: widget.secondaryText,
                        ),
                      ),
                    ))
                .toList(),
          ),

          const SizedBox(height: 10),

          if (_viewMode == 0)
            // Week: single row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: days.map((day) => _moodDot(day)).toList(),
            )
          else
            // Month: grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _daysInMonth(_focusedMonth).length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 4,
              ),
              itemBuilder: (context, i) {
                final cell = _daysInMonth(_focusedMonth)[i];
                if (cell == null) return const SizedBox.shrink();
                return _moodDot(cell);
              },
            ),
        ],
      ),
    );
  }

  Widget _moodDot(DateTime day) {
    final mood = _moodForDay(day);
    final now = DateTime.now();
    final isToday = day.day == now.day &&
        day.month == now.month &&
        day.year == now.year;
    final isFuture = day.isAfter(now);

    Color bg;
    Color textColor;
    if (isFuture) {
      bg = widget.isDark
          ? const Color(0xFF1E1A35).withValues(alpha: 0.4)
          : const Color(0xFFEDE8FF).withValues(alpha: 0.4);
      textColor = widget.secondaryText.withValues(alpha: 0.3);
    } else if (mood != null) {
      bg = moodColor(mood).withValues(alpha: 0.22);
      textColor = moodColor(mood);
    } else {
      bg = widget.isDark
          ? const Color(0xFF2A2445)
          : const Color(0xFFF0EBF8);
      textColor = widget.secondaryText;
    }

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: isToday
            ? Border.all(
                color: widget.isDark
                    ? const Color(0xFF9B7FE8)
                    : const Color(0xFF3D2B8E),
                width: 2,
              )
            : null,
      ),
      child: Center(
        child: mood != null && !isFuture
            ? Icon(moodIcon(mood), size: 15, color: textColor)
            : Text(
                '${day.day}',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
      ),
    );
  }

  // ── Distribution ─────────────────────────────────────────────────────────

  Widget _buildDistributionCard(Color border) {
    final dist = _moodDistribution();
    final total = dist.values.fold(0, (a, b) => a + b);

    const moodOrder = ['Happy', 'Calm', 'Sad', 'Anxious'];

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: widget.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mood Distribution',
            style: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: widget.primaryText,
            ),
          ),
          Text(
            'The moods you\'ve experienced most often',
            style: GoogleFonts.outfit(fontSize: 13, color: widget.secondaryText),
          ),
          const SizedBox(height: 20),

          if (total == 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No data yet',
                  style: GoogleFonts.outfit(
                      color: widget.secondaryText, fontSize: 14),
                ),
              ),
            )
          else ...[
            // Stacked bar
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Row(
                children: moodOrder.map((m) {
                  final count = dist[m] ?? 0;
                  final frac = count / total;
                  if (frac == 0) return const SizedBox.shrink();
                  return Expanded(
                    flex: (frac * 1000).round(),
                    child: Container(
                      height: 14,
                      color: moodColor(m),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            // Legend rows
            ...moodOrder.map((m) {
              final count = dist[m] ?? 0;
              final frac = total > 0 ? count / total : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(moodIcon(m), size: 16, color: moodColor(m)),
                    const SizedBox(width: 10),
                    Text(
                      m,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: widget.primaryText,
                      ),
                    ),
                    const Spacer(),
                    // Mini progress bar
                    SizedBox(
                      width: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: frac.toDouble(),
                          backgroundColor: moodColor(m).withValues(alpha: 0.15),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(moodColor(m)),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$count',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: moodColor(m),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  // ── Streak card ───────────────────────────────────────────────────────────

  Widget _buildStreakCard(Color accent, Color border) {
    // Count consecutive days with entries up to today
    int streak = 0;
    final now = DateTime.now();
    for (int i = 0; i < 365; i++) {
      final day = now.subtract(Duration(days: i));
      final mood = _moodForDay(day);
      if (mood != null) {
        streak++;
      } else {
        break;
      }
    }

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: widget.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accent, accent.withValues(alpha: 0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(CupertinoIcons.flame_fill,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$streak day${streak == 1 ? '' : 's'}',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: accent,
                ),
              ),
              Text(
                'Current streak',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: widget.secondaryText,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${widget.journalEntries.length}',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: widget.primaryText,
                ),
              ),
              Text(
                'total entries',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: widget.secondaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Ring painter for average mood score
// ════════════════════════════════════════════════════════════════════════════
class _RingPainter extends CustomPainter {
  final double score;
  final Color color;

  const _RingPainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy) - 7;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = color.withValues(alpha: 0.15);

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..color = color;

    canvas.drawCircle(Offset(cx, cy), r, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -math.pi / 2,
      2 * math.pi * score,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.score != score || oldDelegate.color != color;
}
