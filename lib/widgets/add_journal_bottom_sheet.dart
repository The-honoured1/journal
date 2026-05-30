import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/journal_entry.dart';
import 'avatar_helper.dart';

class AddJournalBottomSheet extends StatefulWidget {
  final bool isDark;
  final JournalEntry? existingEntry;
  final Function(
    String title,
    String content,
    String category,
    double happy,
    double sad,
    double calm,
    double anxious,
    List<String> imageUrls,
    List<String> fileNames,
    String? voiceNotePath,
    int voiceDurationSec,
  ) onSave;

  const AddJournalBottomSheet({
    super.key,
    required this.isDark,
    required this.onSave,
    this.existingEntry,
  });

  @override
  State<AddJournalBottomSheet> createState() => _AddJournalBottomSheetState();
}

class _AddJournalBottomSheetState extends State<AddJournalBottomSheet>
    with SingleTickerProviderStateMixin {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();

  String selectedCategory = "Personal";

  // Emotion values (0.0 – 1.0)
  double happyVal = 0.5;
  double sadVal = 0.1;
  double calmVal = 0.5;
  double anxiousVal = 0.1;

  // Local images picked from device
  List<XFile> pickedImages = [];

  // Voice recording state
  bool isRecording = false;
  int recordDuration = 0;
  Timer? recordTimer;
  Timer? waveformTimer;
  List<double> waveformPeaks = List.generate(24, (_) => 0.1);
  String? recordedVoicePath;
  int recordedVoiceDuration = 0;

  static const _categories = [
    "Personal", "Work", "Gratitude", "Health", "Venting", "Goals"
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingEntry != null) {
      final e = widget.existingEntry!;
      _titleController.text = e.title;
      _textController.text = e.text;
      selectedCategory = e.categories.isNotEmpty ? e.categories.first : "Personal";
      happyVal = e.happyVal;
      sadVal = e.sadVal;
      calmVal = e.calmVal;
      anxiousVal = e.anxiousVal;
      pickedImages = e.imageUrls.map((path) => XFile(path)).toList();
      recordedVoicePath = e.voiceNotePath;
      recordedVoiceDuration = e.voiceDurationSec;
    } else {
      _loadDailyEmotions();
    }
  }

  void _loadDailyEmotions() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr = "${today.year}-${today.month}-${today.day}";
    if (prefs.getString('last_checkin_date') == todayStr) {
      setState(() {
        happyVal = prefs.getDouble('today_happy') ?? 0.5;
        sadVal = prefs.getDouble('today_sad') ?? 0.1;
        calmVal = prefs.getDouble('today_calm') ?? 0.5;
        anxiousVal = prefs.getDouble('today_anxious') ?? 0.1;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    recordTimer?.cancel();
    waveformTimer?.cancel();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(imageQuality: 80);
    if (images.isNotEmpty) {
      setState(() {
        pickedImages.addAll(images);
      });
    }
  }

  void _startRecording() {
    setState(() {
      isRecording = true;
      recordDuration = 0;
      recordedVoicePath = null;
      recordedVoiceDuration = 0;
    });
    recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => recordDuration++);
    });
    final rand = math.Random();
    waveformTimer = Timer.periodic(const Duration(milliseconds: 120), (_) {
      setState(() {
        waveformPeaks = List.generate(24, (_) => rand.nextDouble() * 0.9 + 0.1);
      });
    });
  }

  void _stopRecording() {
    recordTimer?.cancel();
    waveformTimer?.cancel();
    setState(() {
      isRecording = false;
      recordedVoiceDuration = recordDuration;
      recordedVoicePath = "voice_${DateTime.now().millisecondsSinceEpoch}.wav";
    });
  }

  void _saveEntry() {
    if (_titleController.text.trim().isEmpty || _textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in the title and content"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    widget.onSave(
      _titleController.text.trim(),
      _textController.text.trim(),
      selectedCategory,
      happyVal, sadVal, calmVal, anxiousVal,
      pickedImages.map((f) => f.path).toList(),
      [],
      recordedVoicePath,
      recordedVoiceDuration,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final kb = MediaQuery.of(context).viewInsets.bottom;
    
    // Brand Harmonious spacious tokens
    final bg = widget.isDark ? const Color(0xFF0C100D) : const Color(0xFFF9F7F3);
    final cardBg = widget.isDark ? const Color(0xFF181F1B) : Colors.white;
    final primaryText = widget.isDark ? const Color(0xFFECEFEA) : const Color(0xFF1A1F1C);
    final secondaryText = widget.isDark ? const Color(0xFF8FA397) : const Color(0xFF5A625D);
    final accent = widget.isDark ? const Color(0xFF6A9978) : const Color(0xFF2C5E43);

    final mins = (recordDuration ~/ 60).toString().padLeft(2, '0');
    final secs = (recordDuration % 60).toString().padLeft(2, '0');

    return Container(
      padding: EdgeInsets.only(bottom: kb),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 30, offset: Offset(0, -5)),
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44, height: 6,
                decoration: BoxDecoration(
                  color: secondaryText.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "New Reflection",
                  style: GoogleFonts.outfit(
                    fontSize: 24, fontWeight: FontWeight.bold, color: primaryText,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cardBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(CupertinoIcons.xmark, size: 16, color: secondaryText),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              "Express your mind in a quiet space.",
              style: GoogleFonts.outfit(fontSize: 14, color: secondaryText),
            ),
            const SizedBox(height: 24),

            // ── Title field ──────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _titleController,
                style: GoogleFonts.outfit(
                  color: primaryText, fontWeight: FontWeight.w600, fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: "Give this entry a title...",
                  hintStyle: GoogleFonts.outfit(color: secondaryText),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── Content field ────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _textController,
                maxLines: 5,
                style: GoogleFonts.outfit(color: primaryText, fontSize: 15, height: 1.6),
                decoration: InputDecoration(
                  hintText: "What happened today? Thoughts, feelings, moments...",
                  hintStyle: GoogleFonts.outfit(color: secondaryText, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ── Category chips ───────────────────────────────
            Text(
              "Category",
              style: GoogleFonts.outfit(
                fontSize: 15, fontWeight: FontWeight.bold, color: primaryText,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final sel = selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() => selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                      decoration: BoxDecoration(
                        color: sel ? accent : cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: sel ? null : Border.all(
                          color: secondaryText.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        cat,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : secondaryText,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // ── Media toolbar ────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  _ToolbarBtn(
                    icon: CupertinoIcons.photo,
                    label: "Photo",
                    color: accent,
                    onTap: isRecording ? null : _pickImages,
                  ),
                  const SizedBox(width: 12),
                  _ToolbarBtn(
                    icon: isRecording ? CupertinoIcons.mic_fill : CupertinoIcons.mic,
                    label: isRecording ? "$mins:$secs" : "Record",
                    color: isRecording ? Colors.redAccent : accent,
                    onTap: isRecording ? _stopRecording : _startRecording,
                  ),
                  if (isRecording) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 28,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: waveformPeaks.take(16).map((h) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 100),
                              width: 3,
                              height: 28 * h,
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Picked images strip
            if (pickedImages.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: pickedImages.length,
                  itemBuilder: (context, idx) {
                    return Stack(
                      children: [
                        Container(
                          width: 80,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(
                              image: getAvatarProvider(pickedImages[idx].path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4, right: 14,
                          child: GestureDetector(
                            onTap: () => setState(() => pickedImages.removeAt(idx)),
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Colors.black54, shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 12),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],

            // Voice note chip
            if (recordedVoicePath != null) ...[
              const SizedBox(height: 16),
              Chip(
                backgroundColor: accent.withOpacity(0.12),
                avatar: Icon(CupertinoIcons.mic_fill, size: 14, color: accent),
                label: Text(
                  "Voice note (${recordedVoiceDuration}s)",
                  style: TextStyle(fontSize: 12, color: accent, fontWeight: FontWeight.bold),
                ),
                onDeleted: () => setState(() {
                  recordedVoicePath = null;
                  recordedVoiceDuration = 0;
                }),
                deleteIconColor: accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ],

            const SizedBox(height: 32),

            // ── Save CTA ─────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isRecording ? null : _saveEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Text(
                  "Save Reflection",
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Small toolbar icon button ────────────────────────────────────────────────
class _ToolbarBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ToolbarBtn({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
