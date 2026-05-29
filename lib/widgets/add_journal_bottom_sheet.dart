import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddJournalBottomSheet extends StatefulWidget {
  final bool isDark;
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
    _loadDailyEmotions();
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
    final bg = widget.isDark ? const Color(0xFF1E1A18) : const Color(0xFFF5F2EB);
    final cardBg = widget.isDark ? const Color(0xFF2A2622) : Colors.white;
    final primaryText = widget.isDark ? const Color(0xFFECE7E2) : const Color(0xFF2C2A29);
    final secondaryText = widget.isDark ? const Color(0xFF9E9992) : const Color(0xFF7C7975);
    const accent = Color(0xFFFFB534);

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
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40, height: 5,
                decoration: BoxDecoration(
                  color: secondaryText.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "My Journal",
                  style: GoogleFonts.outfit(
                    fontSize: 22, fontWeight: FontWeight.bold, color: primaryText,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: cardBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(CupertinoIcons.xmark, size: 16, color: secondaryText),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Celebrate what made you smile today.",
              style: GoogleFonts.outfit(fontSize: 13, color: secondaryText),
            ),
            const SizedBox(height: 20),

            // ── Title field ──────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(18),
              ),
              child: TextField(
                controller: _titleController,
                style: GoogleFonts.outfit(
                  color: primaryText, fontWeight: FontWeight.w600, fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: "Give this entry a title...",
                  hintStyle: GoogleFonts.outfit(color: secondaryText),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ── Content field ────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(18),
              ),
              child: TextField(
                controller: _textController,
                maxLines: 4,
                style: GoogleFonts.outfit(color: primaryText, fontSize: 14, height: 1.5),
                decoration: InputDecoration(
                  hintText: "What happened today? Thoughts, feelings, moments...",
                  hintStyle: GoogleFonts.outfit(color: secondaryText, fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),



            // ── Category chips ───────────────────────────────
            Text(
              "Category",
              style: GoogleFonts.outfit(
                fontSize: 14, fontWeight: FontWeight.bold, color: primaryText,
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final sel = selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() => selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(
                        color: sel ? accent : cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: sel ? null : Border.all(
                          color: secondaryText.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        cat,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: sel ? const Color(0xFF2C2A29) : secondaryText,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // ── Media toolbar ────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  _ToolbarBtn(
                    icon: CupertinoIcons.photo,
                    label: "Photo",
                    color: accent,
                    onTap: isRecording ? null : _pickImages,
                  ),
                  const SizedBox(width: 4),
                  _ToolbarBtn(
                    icon: isRecording ? CupertinoIcons.mic_fill : CupertinoIcons.mic,
                    label: isRecording ? "$mins:$secs" : "Record",
                    color: isRecording ? Colors.redAccent : accent,
                    onTap: isRecording ? _stopRecording : _startRecording,
                  ),
                  if (isRecording) ...[
                    const SizedBox(width: 8),
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
              const SizedBox(height: 12),
              SizedBox(
                height: 76,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: pickedImages.length,
                  itemBuilder: (context, idx) {
                    return Stack(
                      children: [
                        Container(
                          width: 76,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            image: DecorationImage(
                              image: FileImage(File(pickedImages[idx].path)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4, right: 12,
                          child: GestureDetector(
                            onTap: () => setState(() => pickedImages.removeAt(idx)),
                            child: Container(
                              padding: const EdgeInsets.all(2),
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
              const SizedBox(height: 12),
              Chip(
                backgroundColor: accent.withOpacity(0.12),
                avatar: const Icon(CupertinoIcons.mic_fill, size: 14, color: Color(0xFFFFB534)),
                label: Text(
                  "Voice note (${recordedVoiceDuration}s)",
                  style: const TextStyle(fontSize: 11, color: Color(0xFFFFB534), fontWeight: FontWeight.bold),
                ),
                onDeleted: () => setState(() {
                  recordedVoicePath = null;
                  recordedVoiceDuration = 0;
                }),
                deleteIconColor: const Color(0xFFFFB534),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ],

            const SizedBox(height: 24),

            // ── Save CTA ─────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isRecording ? null : _saveEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: const Color(0xFF2C2A29),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Text(
                  "Create a New Journal",
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C2A29),
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
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
