import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddJournalBottomSheet extends StatefulWidget {
  final bool isDark;
  final Function(String, String, String, double, double, double, double) onSave;

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
  String selectedCategory = "Personal";

  double happyVal = 0.8;
  double sadVal = 0.1;
  double calmVal = 0.6;
  double anxiousVal = 0.2;

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final primaryTextColor = widget.isDark ? const Color(0xFFECE7E2) : const Color(0xFF2C2A29);
    final cardColor = widget.isDark ? const Color(0xFF24211F) : Colors.white;

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
            const SizedBox(height: 20),
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
                onPressed: () {
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
