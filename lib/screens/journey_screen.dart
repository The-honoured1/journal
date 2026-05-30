import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/journal_entry.dart';

class JourneyScreen extends StatefulWidget {
  final bool isDark;
  final Color primaryText;
  final Color secondaryText;
  final Color cardBg;
  final List<JournalEntry> journalEntries;
  final void Function(JournalEntry) onOpenJournal;

  const JourneyScreen({
    super.key,
    required this.isDark,
    required this.primaryText,
    required this.secondaryText,
    required this.cardBg,
    required this.journalEntries,
    required this.onOpenJournal,
  });

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── helpers ────────────────────────────────────────────────────────────────

  /// Parse "Month Day, Year" → DateTime (falls back to epoch)
  DateTime _parseDate(String raw) {
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
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  String _relativeDay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '${diff} days ago';
    return '';
  }

  String _shortDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _dayOfWeek(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[(date.weekday - 1) % 7];
  }

  Color _moodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':  return const Color(0xFFFFB347);
      case 'sad':    return const Color(0xFF6EB5FF);
      case 'anxious':return const Color(0xFFFF7F7F);
      case 'calm':   return const Color(0xFF7FE8C2);
      default:       return const Color(0xFF9B7FE8);
    }
  }

  IconData _moodIcon(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':  return CupertinoIcons.sun_max_fill;
      case 'sad':    return CupertinoIcons.cloud_rain_fill;
      case 'anxious':return CupertinoIcons.bolt_fill;
      case 'calm':   return CupertinoIcons.leaf_arrow_circlepath;
      default:       return CupertinoIcons.moon_stars_fill;
    }
  }

  // ── group entries by day ───────────────────────────────────────────────────

  List<MapEntry<DateTime, List<JournalEntry>>> _groupedByDay() {
    final map = <String, MapEntry<DateTime, List<JournalEntry>>>{};
    for (final entry in widget.journalEntries) {
      final dt = _parseDate(entry.date);
      final key = '${dt.year}-${dt.month}-${dt.day}';
      if (!map.containsKey(key)) {
        map[key] = MapEntry(dt, []);
      }
      map[key]!.value.add(entry);
    }
    final sorted = map.values.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    return sorted;
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final bg = isDark ? const Color(0xFF0E0C1A) : const Color(0xFFF5F0E8);
    final accentPurple = isDark ? const Color(0xFF9B7FE8) : const Color(0xFF5A3FBF);
    final timelineColor =
        isDark ? const Color(0xFF2A2445) : const Color(0xFFDDD7F0);

    final groups = _groupedByDay();

    return Container(
      color: bg,
      child: groups.isEmpty
          ? _buildEmpty(isDark, accentPurple)
          : CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── subtle top spacer ──────────────────────────────────────
                const SliverToBoxAdapter(child: SizedBox(height: 8)),

                // ── day groups ────────────────────────────────────────────
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final group = groups[i];
                      return _DayGroup(
                        date: group.key,
                        entries: group.value,
                        isDark: isDark,
                        primaryText: widget.primaryText,
                        secondaryText: widget.secondaryText,
                        cardBg: widget.cardBg,
                        accentPurple: accentPurple,
                        timelineColor: timelineColor,
                        isLast: i == groups.length - 1,
                        relativeDay: _relativeDay(group.key),
                        shortDate: _shortDate(group.key),
                        dayOfWeek: _dayOfWeek(group.key),
                        moodColor: _moodColor,
                        moodIcon: _moodIcon,
                        onOpenJournal: widget.onOpenJournal,
                        animIndex: i,
                      );
                    },
                    childCount: groups.length,
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
    );
  }

  Widget _buildEmpty(bool isDark, Color accentPurple) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  accentPurple.withOpacity(0.18),
                  accentPurple.withOpacity(0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(
              CupertinoIcons.map,
              size: 40,
              color: accentPurple.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your journey starts here.',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'serif',
              fontWeight: FontWeight.w700,
              color: widget.primaryText,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Write your first entry and watch\nyour story unfold over time.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: widget.secondaryText,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// DayGroup widget — one row per day on the timeline
// ════════════════════════════════════════════════════════════════════════════

class _DayGroup extends StatelessWidget {
  final DateTime date;
  final List<JournalEntry> entries;
  final bool isDark;
  final Color primaryText;
  final Color secondaryText;
  final Color cardBg;
  final Color accentPurple;
  final Color timelineColor;
  final bool isLast;
  final String relativeDay;
  final String shortDate;
  final String dayOfWeek;
  final Color Function(String) moodColor;
  final IconData Function(String) moodIcon;
  final void Function(JournalEntry) onOpenJournal;
  final int animIndex;

  const _DayGroup({
    required this.date,
    required this.entries,
    required this.isDark,
    required this.primaryText,
    required this.secondaryText,
    required this.cardBg,
    required this.accentPurple,
    required this.timelineColor,
    required this.isLast,
    required this.relativeDay,
    required this.shortDate,
    required this.dayOfWeek,
    required this.moodColor,
    required this.moodIcon,
    required this.onOpenJournal,
    required this.animIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Timeline column ────────────────────────────────────────────
            SizedBox(
              width: 56,
              child: Column(
                children: [
                  // Node dot
                  _TimelineNode(
                    isDark: isDark,
                    accentPurple: accentPurple,
                    dayNumber: date.day,
                    primaryText: primaryText,
                  ),
                  // Vertical line continuing downward
                  if (!isLast)
                    Expanded(
                      child: Center(
                        child: Container(
                          width: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                timelineColor,
                                timelineColor.withOpacity(0.2),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (isLast) const SizedBox(height: 16),
                ],
              ),
            ),

            const SizedBox(width: 14),

            // ── Content column ─────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    // Day label row
                    Row(
                      children: [
                        if (relativeDay.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: accentPurple.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              relativeDay,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: accentPurple,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          '$dayOfWeek · $shortDate',
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Entry cards
                    ...entries.map((e) => _EntryCard(
                          entry: e,
                          isDark: isDark,
                          primaryText: primaryText,
                          secondaryText: secondaryText,
                          cardBg: cardBg,
                          accentPurple: accentPurple,
                          moodColor: moodColor(e.mood),
                          moodIcon: moodIcon(e.mood),
                          onTap: () => onOpenJournal(e),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Timeline node — the decorative circle on the left rail
// ════════════════════════════════════════════════════════════════════════════

class _TimelineNode extends StatelessWidget {
  final bool isDark;
  final Color accentPurple;
  final int dayNumber;
  final Color primaryText;

  const _TimelineNode({
    required this.isDark,
    required this.accentPurple,
    required this.dayNumber,
    required this.primaryText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            accentPurple,
            accentPurple.withOpacity(0.65),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: accentPurple.withOpacity(0.32),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$dayNumber',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// EntryCard — a single journal card on the Journey timeline
// ════════════════════════════════════════════════════════════════════════════

class _EntryCard extends StatefulWidget {
  final JournalEntry entry;
  final bool isDark;
  final Color primaryText;
  final Color secondaryText;
  final Color cardBg;
  final Color accentPurple;
  final Color moodColor;
  final IconData moodIcon;
  final VoidCallback onTap;

  const _EntryCard({
    required this.entry,
    required this.isDark,
    required this.primaryText,
    required this.secondaryText,
    required this.cardBg,
    required this.accentPurple,
    required this.moodColor,
    required this.moodIcon,
    required this.onTap,
  });

  @override
  State<_EntryCard> createState() => _EntryCardState();
}

class _EntryCardState extends State<_EntryCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = Tween<double>(begin: 0.97, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _ctrl.reverse();
  void _onTapUp(_) {
    _ctrl.forward();
    widget.onTap();
  }
  void _onTapCancel() => _ctrl.forward();

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    final isDark = widget.isDark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ScaleTransition(
        scale: _scale,
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: Container(
            decoration: BoxDecoration(
              color: widget.cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.moodColor.withOpacity(0.18),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? const Color(0x18000000)
                      : const Color(0x0C000000),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Mood accent bar at top ─────────────────────────────────
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        widget.moodColor,
                        widget.moodColor.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header row ────────────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              e.title.isEmpty ? 'Untitled' : e.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: widget.primaryText,
                                fontFamily: 'serif',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Mood badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: widget.moodColor.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  widget.moodIcon,
                                  size: 12,
                                  color: widget.moodColor,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  e.mood,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: widget.moodColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // ── Body preview ──────────────────────────────────────
                      if (e.text.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          e.text.trim(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: widget.secondaryText,
                            height: 1.55,
                          ),
                        ),
                      ],

                      // ── Footer row ────────────────────────────────────────
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Categories chips
                          if (e.categories.isNotEmpty)
                            Expanded(
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: e.categories.take(2).map((cat) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF2A2445)
                                          : const Color(0xFFEDE8FF),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      cat,
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        color: widget.accentPurple,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          // Attachments indicators
                          if (e.voiceDurationSec > 0)
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Icon(
                                CupertinoIcons.waveform,
                                size: 15,
                                color: widget.secondaryText.withOpacity(0.7),
                              ),
                            ),
                          if (e.imageUrls.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    CupertinoIcons.photo,
                                    size: 14,
                                    color: widget.secondaryText.withOpacity(0.7),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${e.imageUrls.length}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: widget.secondaryText.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // Arrow
                          const SizedBox(width: 6),
                          Icon(
                            CupertinoIcons.chevron_right,
                            size: 13,
                            color: widget.secondaryText.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
