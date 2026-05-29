import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/audio_waveform.dart';

class ReflectionScreen extends StatelessWidget {
  final Map<String, dynamic> entry;
  final bool isDark;
  final Color primaryText;
  final Color secondaryText;
  final Color cardBg;
  final bool isPlaying;
  final int playbackSeconds;
  final double playbackProgress;
  final Set<String> selectedCategories;
  final VoidCallback onPlayToggle;
  final VoidCallback onBack;
  final VoidCallback onDelete;
  final ValueChanged<String> onCategoryToggle;

  const ReflectionScreen({
    super.key,
    required this.entry,
    required this.isDark,
    required this.primaryText,
    required this.secondaryText,
    required this.cardBg,
    required this.isPlaying,
    required this.playbackSeconds,
    required this.playbackProgress,
    required this.onBack,
    required this.onPlayToggle,
    required this.onDelete,
    required this.selectedCategories,
    required this.onCategoryToggle,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = (playbackSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (playbackSeconds % 60).toString().padLeft(2, '0');
    final scaffoldBg = isDark ? const Color(0xFF1C1A18) : const Color(0xFFF5F2EB);

    return Stack(
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: 20, right: 20, top: 70, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    entry["date"] ?? "March 22, 2025",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFFB534),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    entry["title"] ?? "Morning Reflection",
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: primaryText,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: ["Personal", "Calm", "Motivation"].map((category) {
                    final isActive = selectedCategories.contains(category);
                    return GestureDetector(
                      onTap: () => onCategoryToggle(category),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFFFFB534)
                              : (isDark ? const Color(0xFF282522) : Colors.white),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isActive
                                ? const Color(0xFFFFB534)
                                : primaryText.withOpacity(0.08),
                          ),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isActive
                                ? const Color(0xFF2C2A29)
                                : secondaryText,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    height: 220,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFECE7E2),
                      image: DecorationImage(
                        image: NetworkImage(
                          "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=600&auto=format&fit=crop&q=80",
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.2),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: onPlayToggle,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFB534),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isPlaying ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                            color: const Color(0xFF2C2A29),
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: SizedBox(
                          height: 36,
                          child: AudioWaveform(
                            progress: playbackProgress,
                            isPlaying: isPlaying,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        "$minutes:$seconds",
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          color: primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  entry["text"] ?? "No text entered.",
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 16,
                    height: 1.6,
                    color: primaryText.withOpacity(0.85),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Tiny Graces",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: primaryText,
                  ),
                ),
                const SizedBox(height: 12),
                ...List.generate(
                  (entry["bullets"] as List).length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 5.0),
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Color(0xFFFFB534),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry["bullets"][index],
                            style: TextStyle(
                              fontSize: 14,
                              color: secondaryText,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  scaffoldBg,
                  scaffoldBg.withOpacity(0.9),
                  scaffoldBg.withOpacity(0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: onBack,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: cardBg,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 5,
                        )
                      ],
                    ),
                    child: Icon(
                      CupertinoIcons.left_chevron,
                      color: primaryText,
                      size: 18,
                    ),
                  ),
                ),
                Text(
                  "Reflection detail",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: secondaryText,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    CupertinoIcons.ellipsis,
                    color: primaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 24,
          left: 40,
          right: 40,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(CupertinoIcons.pencil, color: Color(0xFFFFB534)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Editing reflection..."),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(CupertinoIcons.share, color: secondaryText),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Preparing share layout..."),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.trash, color: Color(0xFF78473B)),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
