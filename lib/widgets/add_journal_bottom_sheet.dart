import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

class _AddJournalBottomSheetState extends State<AddJournalBottomSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _fileNameController = TextEditingController();
  
  String selectedCategory = "Personal";

  double happyVal = 0.8;
  double sadVal = 0.1;
  double calmVal = 0.6;
  double anxiousVal = 0.2;

  // Rich attachments state
  List<String> attachedImageUrls = [];
  List<String> attachedFileNames = [];
  
  // Voice recording state
  bool isRecording = false;
  int recordDuration = 0;
  Timer? recordTimer;
  Timer? waveformTimer;
  List<double> waveformPeaks = List.generate(24, (_) => 0.1);
  
  String? recordedVoicePath;
  int recordedVoiceDuration = 0;

  // Curated premium Unsplash ambient presets matching Solace branding
  final List<Map<String, String>> ambientPresets = [
    {
      "name": "Pine Forest",
      "url": "https://images.unsplash.com/photo-1502082553048-f009c37129b9?w=500&auto=format&fit=crop&q=80"
    },
    {
      "name": "Soft Sunrise",
      "url": "https://images.unsplash.com/photo-1470252649378-9c29740c9fa8?w=500&auto=format&fit=crop&q=80"
    },
    {
      "name": "Warm Tea",
      "url": "https://images.unsplash.com/photo-1576092768241-dec231879fc3?w=500&auto=format&fit=crop&q=80"
    },
    {
      "name": "Cozy Study",
      "url": "https://images.unsplash.com/photo-1507842217343-583bb7270b66?w=500&auto=format&fit=crop&q=80"
    },
    {
      "name": "Rainy Day",
      "url": "https://images.unsplash.com/photo-1515694346937-94d85e41e6f0?w=500&auto=format&fit=crop&q=80"
    },
    {
      "name": "Calm Ocean",
      "url": "https://images.unsplash.com/photo-1505118380757-91f5f5632de0?w=500&auto=format&fit=crop&q=80"
    },
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    _imageUrlController.dispose();
    _fileNameController.dispose();
    recordTimer?.cancel();
    waveformTimer?.cancel();
    super.dispose();
  }

  void startRecording() {
    setState(() {
      isRecording = true;
      recordDuration = 0;
      recordedVoicePath = null;
      recordedVoiceDuration = 0;
    });

    recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        recordDuration++;
      });
    });

    final rand = math.Random();
    waveformTimer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      setState(() {
        waveformPeaks = List.generate(24, (_) => rand.nextDouble() * 0.9 + 0.1);
      });
    });
  }

  void stopRecording() {
    recordTimer?.cancel();
    waveformTimer?.cancel();
    setState(() {
      isRecording = false;
      recordedVoiceDuration = recordDuration;
      recordedVoicePath = "voice_recording_${DateTime.now().millisecondsSinceEpoch}.wav";
    });
  }

  void showAddImageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: widget.isDark ? const Color(0xFF282522) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(
                "Attach an Image",
                style: TextStyle(
                  fontFamily: 'serif',
                  fontWeight: FontWeight.bold,
                  color: widget.isDark ? Colors.white : Colors.black,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Choose from ambient presets:",
                      style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: ambientPresets.length,
                        itemBuilder: (context, idx) {
                          final preset = ambientPresets[idx];
                          final isSelected = attachedImageUrls.contains(preset["url"]);
                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                if (isSelected) {
                                  attachedImageUrls.remove(preset["url"]!);
                                } else {
                                  attachedImageUrls.add(preset["url"]!);
                                }
                              });
                              setState(() {});
                            },
                            child: Container(
                              width: 90,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFFFFB534) : Colors.transparent,
                                  width: 2.5,
                                ),
                                image: DecorationImage(
                                  image: NetworkImage(preset["url"]!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black45,
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(13),
                                          bottomRight: Radius.circular(13),
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Text(
                                        preset["name"]!,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Positioned(
                                      top: 4,
                                      right: 4,
                                      child: Icon(Icons.check_circle, color: Color(0xFFFFB534), size: 18),
                                    )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Or enter custom image URL:",
                      style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _imageUrlController,
                      decoration: InputDecoration(
                        hintText: "https://example.com/image.jpg",
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                        filled: true,
                        fillColor: widget.isDark ? Colors.black12 : const Color(0xFFF7F5F2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      style: TextStyle(color: widget.isDark ? Colors.white : Colors.black, fontSize: 13),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_imageUrlController.text.trim().isNotEmpty) {
                      setState(() {
                        attachedImageUrls.add(_imageUrlController.text.trim());
                      });
                      _imageUrlController.clear();
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB534),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Done", style: TextStyle(color: Color(0xFF2C2A29), fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showAddFileDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: widget.isDark ? const Color(0xFF282522) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            "Attach a File",
            style: TextStyle(
              fontFamily: 'serif',
              fontWeight: FontWeight.bold,
              color: widget.isDark ? Colors.white : Colors.black,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Enter file name to attach:",
                style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _fileNameController,
                decoration: InputDecoration(
                  hintText: "meditation_guide.pdf",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                  filled: true,
                  fillColor: widget.isDark ? Colors.black12 : const Color(0xFFF7F5F2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                style: TextStyle(color: widget.isDark ? Colors.white : Colors.black, fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                final file = _fileNameController.text.trim();
                if (file.isNotEmpty) {
                  setState(() {
                    attachedFileNames.add(file);
                  });
                  _fileNameController.clear();
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB534),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Attach", style: TextStyle(color: Color(0xFF2C2A29), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final primaryTextColor = widget.isDark ? const Color(0xFFECE7E2) : const Color(0xFF2C2A29);
    final cardColor = widget.isDark ? const Color(0xFF24211F) : Colors.white;

    final minutes = (recordDuration ~/ 60).toString().padLeft(2, '0');
    final seconds = (recordDuration % 60).toString().padLeft(2, '0');

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: keyboardHeight + 30,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(36),
          topRight: Radius.circular(36),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 30,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "New Reflection",
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(CupertinoIcons.clear_thick_circled, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: "Title of reflection...",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: widget.isDark ? Colors.black12 : const Color(0xFFF7F5F2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _textController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "How are you feeling inside? What made you smile today...",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: widget.isDark ? Colors.black12 : const Color(0xFFF7F5F2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              style: TextStyle(color: primaryTextColor, height: 1.4),
            ),
            
            // Attached media displays
            if (attachedImageUrls.isNotEmpty || attachedFileNames.isNotEmpty || recordedVoicePath != null) ...[
              const SizedBox(height: 16),
              Text(
                "Attached Media",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryTextColor),
              ),
              const SizedBox(height: 8),
              
              // Images horizontal list
              if (attachedImageUrls.isNotEmpty) ...[
                SizedBox(
                  height: 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: attachedImageUrls.length,
                    itemBuilder: (context, idx) {
                      final url = attachedImageUrls[idx];
                      return Container(
                        width: 70,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(url),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                attachedImageUrls.removeAt(idx);
                              });
                            },
                            child: Container(
                              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                              padding: const EdgeInsets.all(2),
                              margin: const EdgeInsets.all(3),
                              child: const Icon(Icons.close, color: Colors.white, size: 12),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
              
              // Files/Audio list
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (recordedVoicePath != null)
                    Chip(
                      backgroundColor: const Color(0xFFFFB534).withOpacity(0.15),
                      avatar: const Icon(CupertinoIcons.mic_fill, size: 14, color: Color(0xFFFFB534)),
                      label: Text("Audio Note (${recordedVoiceDuration}s)", style: const TextStyle(fontSize: 11, color: Color(0xFFFFB534), fontWeight: FontWeight.bold)),
                      onDeleted: () {
                        setState(() {
                          recordedVoicePath = null;
                          recordedVoiceDuration = 0;
                        });
                      },
                      deleteIconColor: const Color(0xFFFFB534),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ...attachedFileNames.map((name) => Chip(
                    backgroundColor: widget.isDark ? Colors.black26 : const Color(0xFFF0EFEB),
                    avatar: Icon(CupertinoIcons.paperclip, size: 14, color: primaryTextColor),
                    label: Text(name, style: TextStyle(fontSize: 11, color: primaryTextColor)),
                    onDeleted: () {
                      setState(() {
                        attachedFileNames.remove(name);
                      });
                    },
                    deleteIconColor: Colors.grey,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  )),
                ],
              ),
            ],

            // Active Voice Recording Panel
            if (isRecording) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB534).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFB534).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    // Pulsing Dot
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.3, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          ),
                        );
                      },
                      onEnd: () {}, // Handled by repeating
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Recording  $minutes:$seconds",
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Waveform visualizer peaks
                    Expanded(
                      child: SizedBox(
                        height: 24,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: waveformPeaks.map((peakHeight) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 100),
                              width: 3,
                              height: 24 * peakHeight,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFB534),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: stopRecording,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: const Icon(Icons.stop, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),
            Row(
              children: [
                // Media Toolbar
                IconButton(
                  icon: const Icon(CupertinoIcons.photo),
                  color: const Color(0xFFFFB534),
                  onPressed: isRecording ? null : showAddImageDialog,
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.paperclip),
                  color: const Color(0xFFFFB534),
                  onPressed: isRecording ? null : showAddFileDialog,
                ),
                IconButton(
                  icon: Icon(isRecording ? CupertinoIcons.mic_fill : CupertinoIcons.mic),
                  color: isRecording ? Colors.red : const Color(0xFFFFB534),
                  onPressed: () {
                    if (isRecording) {
                      stopRecording();
                    } else {
                      startRecording();
                    }
                  },
                ),
                const Spacer(),
                Text(
                  selectedCategory,
                  style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Text(
              "Category",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryTextColor),
            ),
            const SizedBox(height: 8),
            Row(
              children: ["Personal", "Calm", "Motivation"].map((category) {
                final isSel = selectedCategory == category;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFFFFB534) : (widget.isDark ? Colors.black26 : const Color(0xFFF7F5F2)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSel ? const Color(0xFF2C2A29) : Colors.grey,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text(
              "Rate Today's Emotions",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryTextColor),
            ),
            const SizedBox(height: 12),
            _buildEmotionSlider("Happy 😊", happyVal, (v) => setState(() => happyVal = v), const Color(0xFFFFB534)),
            _buildEmotionSlider("Sad 😔", sadVal, (v) => setState(() => sadVal = v), const Color(0xFF78473B)),
            _buildEmotionSlider("Calm 🍃", calmVal, (v) => setState(() => calmVal = v), const Color(0xFF8BA64F)),
            _buildEmotionSlider("Anxious 🌪️", anxiousVal, (v) => setState(() => anxiousVal = v), const Color(0xFF7A7C75)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isRecording
                    ? null
                    : () {
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
                          _titleController.text,
                          _textController.text,
                          selectedCategory,
                          happyVal,
                          sadVal,
                          calmVal,
                          anxiousVal,
                          attachedImageUrls,
                          attachedFileNames,
                          recordedVoicePath,
                          recordedVoiceDuration,
                        );
                        Navigator.pop(context);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB534),
                  foregroundColor: const Color(0xFF2C2A29),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                  elevation: 0,
                ),
                child: const Text(
                  "Save Reflection",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionSlider(String label, double val, ValueChanged<double> onChange, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: color,
                inactiveTrackColor: color.withOpacity(0.15),
                thumbColor: color,
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              ),
              child: Slider(
                value: val,
                onChanged: onChange,
              ),
            ),
          ),
          Text(
            "${(val * 100).toInt()}%",
            style: const TextStyle(fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
