import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

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

class _DailyCheckinModalState extends State<DailyCheckinModal>
    with SingleTickerProviderStateMixin {
  final TextEditingController _noteController = TextEditingController();
  int _step = 0; // 0 = pick emotions, 1 = write note
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  // All emotion words grouped by valence
  static const _emotions = [
    // Negative
    'annoyed', 'anxious', 'fearful',
    'depressed', 'sad', 'lonely',
    'guilty', 'shame', 'angry', 'tired',
    'bored', 'overwhelmed', 'unmotivated',
    // Neutral / mixed
    'calm', 'relaxed',
    // Positive
    'productive', 'content',
    'grateful', 'confident', 'proud',
    'love', 'happy', 'excited',
  ];

  final Set<String> _selected = {};

  // Map emotion → mood scores
  double get _happy {
    const positives = {'happy', 'excited', 'love', 'proud', 'confident', 'grateful', 'content', 'productive'};
    final count = _selected.intersection(positives).length;
    return (_selected.isEmpty ? 0.5 : count / _selected.length).clamp(0.0, 1.0);
  }

  double get _sad {
    const negatives = {'sad', 'depressed', 'lonely', 'guilty', 'shame', 'bored'};
    final count = _selected.intersection(negatives).length;
    return (_selected.isEmpty ? 0.1 : count / _selected.length).clamp(0.0, 1.0);
  }

  double get _calm {
    const calmWords = {'calm', 'relaxed', 'content', 'grateful'};
    final count = _selected.intersection(calmWords).length;
    return (_selected.isEmpty ? 0.5 : count / _selected.length).clamp(0.0, 1.0);
  }

  double get _anxious {
    const anxiousWords = {'anxious', 'fearful', 'angry', 'overwhelmed', 'annoyed', 'tired', 'unmotivated'};
    final count = _selected.intersection(anxiousWords).length;
    return (_selected.isEmpty ? 0.1 : count / _selected.length).clamp(0.0, 1.0);
  }

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 320));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _goNext() async {
    await _fadeCtrl.reverse();
    setState(() => _step = 1);
    _fadeCtrl.forward();
  }

  void _goBack() async {
    await _fadeCtrl.reverse();
    setState(() => _step = 0);
    _fadeCtrl.forward();
  }

  void _submit() {
    widget.onComplete(_happy, _sad, _calm, _anxious, _noteController.text);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final bg = isDark ? const Color(0xFF0E0C1A) : const Color(0xFFFFFDF8);
    final primaryText = isDark ? const Color(0xFFEDE8FF) : const Color(0xFF1A1628);
    final secondaryText = isDark ? const Color(0xFF8880A8) : const Color(0xFF6B6282);
    final accent = isDark ? const Color(0xFF9B7FE8) : const Color(0xFF3D2B8E);
    final chipBorder = isDark ? const Color(0xFF2E2A4A) : const Color(0xFFDDD7F0);
    final selectedBg = accent; // Use theme accent color for better visual styling

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: 420,
          ),
          decoration: BoxDecoration(
            color: bg.withOpacity(isDark ? 0.65 : 0.85),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 48,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: _step == 0
                    ? _buildStep0(bg, primaryText, secondaryText, accent, chipBorder, selectedBg)
                    : _buildStep1(bg, primaryText, secondaryText, accent, chipBorder),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Step 0: emotion picker ────────────────────────────────────────────────
  Widget _buildStep0(
    Color bg, Color primary, Color secondary, Color accent,
    Color chipBorder, Color selectedBg,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Handle bar
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 14, bottom: 6),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: chipBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        // Top navigation row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            children: [
              const SizedBox(width: 32),
              const Spacer(),
              GestureDetector(
                onTap: _submit,
                child: Text(
                  'Skip',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    color: secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Title
        Padding(
          padding: const EdgeInsets.fromLTRB(26, 8, 26, 4),
          child: Text(
            'What emotions do\nyou feel right now?',
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: primary,
              height: 1.25,
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(26, 4, 26, 18),
          child: Text(
            _selected.isEmpty
                ? 'Select all that apply'
                : '${_selected.length} selected',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: secondary,
            ),
          ),
        ),

        // Emotion chips
        Flexible(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _emotions.map((word) {
                final isSelected = _selected.contains(word);
                return _EmotionChip(
                  label: word,
                  isSelected: isSelected,
                  selectedBg: selectedBg,
                  chipBorder: chipBorder,
                  primaryText: primary,
                  accent: accent,
                  onTap: () => setState(() {
                    if (isSelected) {
                      _selected.remove(word);
                    } else {
                      _selected.add(word);
                    }
                  }),
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Next button
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
          child: SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: _selected.isEmpty ? null : _goNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                disabledBackgroundColor:
                    widget.isDark ? const Color(0xFF2E2A4A) : const Color(0xFFDDD7F0),
                foregroundColor: widget.isDark
                    ? const Color(0xFF0E0C1A)
                    : const Color(0xFFFFFDF8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Text(
                'next',
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: widget.isDark ? const Color(0xFF0E0C1A) : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Step 1: optional note ─────────────────────────────────────────────────
  Widget _buildStep1(
    Color bg, Color primary, Color secondary, Color accent, Color chipBorder,
  ) {
    final isDark = widget.isDark;
    final cardBg = isDark ? const Color(0xFF1E1A35) : const Color(0xFFF5F0E8);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Handle bar
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 14, bottom: 6),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: chipBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        // Back row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: GestureDetector(
            onTap: _goBack,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.chevron_left, size: 18, color: secondary),
                const SizedBox(width: 4),
                Text(
                  'Back',
                  style: GoogleFonts.outfit(fontSize: 15, color: secondary),
                ),
              ],
            ),
          ),
        ),

        // Selected emotions recap
        Padding(
          padding: const EdgeInsets.fromLTRB(26, 8, 26, 16),
          child: Text(
            'Feeling: ${_selected.take(4).join(', ')}${_selected.length > 4 ? ' +${_selected.length - 4} more' : ''}',
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: accent,
            ),
          ),
        ),

        // Title
        Padding(
          padding: const EdgeInsets.fromLTRB(26, 0, 26, 8),
          child: Text(
            'Anything else on\nyour mind?',
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: primary,
              height: 1.25,
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(26, 0, 26, 20),
          child: Text(
            'Optional — write a quick note for yourself.',
            style: GoogleFonts.outfit(fontSize: 14, color: secondary),
          ),
        ),

        // Text field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: chipBorder),
            ),
            child: TextField(
              controller: _noteController,
              maxLines: 4,
              style: GoogleFonts.outfit(
                color: primary,
                fontSize: 15,
                height: 1.55,
              ),
              decoration: InputDecoration(
                hintText: 'Write freely here...',
                hintStyle: GoogleFonts.outfit(color: secondary, fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(18),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Done button
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
          child: SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Text(
                'done',
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isDark ? const Color(0xFF0E0C1A) : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Single emotion chip
// ════════════════════════════════════════════════════════════════════════════
class _EmotionChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final Color selectedBg;
  final Color chipBorder;
  final Color primaryText;
  final Color accent;
  final VoidCallback onTap;

  const _EmotionChip({
    required this.label,
    required this.isSelected,
    required this.selectedBg,
    required this.chipBorder,
    required this.primaryText,
    required this.accent,
    required this.onTap,
  });

  @override
  State<_EmotionChip> createState() => _EmotionChipState();
}

class _EmotionChipState extends State<_EmotionChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = Tween<double>(begin: 0.92, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.reverse(),
        onTapUp: (_) {
          _ctrl.forward();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.forward(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.selectedBg
                : widget.primaryText.withOpacity(0.04),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: widget.isSelected
                  ? widget.selectedBg
                  : widget.chipBorder.withOpacity(0.6),
              width: 1.5,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: widget.selectedBg.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ]
                : [],
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: widget.isSelected ? Colors.white : widget.primaryText.withOpacity(0.8),
            ),
          ),
        ),
      ),
    );
  }
}
