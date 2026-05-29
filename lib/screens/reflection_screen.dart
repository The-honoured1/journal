import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/journal_entry.dart';
import '../widgets/audio_waveform.dart';

class ReflectionScreen extends StatelessWidget {
  final JournalEntry entry;
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

    final hasImages = entry.imageUrls.isNotEmpty;
    final hasAudio = entry.voiceNotePath != null;
    final hasFiles = entry.fileNames.isNotEmpty;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(left: 20, right: 20, top: 70, bottom: 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date
                  Center(
                    child: Text(
                      entry.date,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF8E5A3C),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  
                  // Title
                  Center(
                    child: Text(
                      entry.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: primaryText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Category pills
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: entry.categories.map((category) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB534).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFFFB534).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFFB534),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  
                  // Render Images if attached, else default ambient placeholder
                  if (hasImages)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: SizedBox(
                        height: 220,
                        child: PageView.builder(
                          itemCount: entry.imageUrls.length,
                          itemBuilder: (context, idx) {
                            return Image.network(
                              entry.imageUrls[idx],
                              fit: BoxFit.cover,
                              width: double.infinity,
                            );
                          },
                        ),
                      ),
                    )
                  else
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xFFECE7E2),
                          image: DecorationImage(
                            image: NetworkImage(
                              "https://images.unsplash.com/photo-1502082553048-f009c37129b9?w=600&auto=format&fit=crop&q=80",
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 20),
                  
                  // Audio player if voice note exists
                  if (hasAudio) ...[
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
                  ],
                  
                  // Reflection Text
                  Text(
                    entry.text,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      height: 1.6,
                      color: primaryText.withOpacity(0.85),
                    ),
                  ),
                  
                  // File attachments list
                  if (hasFiles) ...[
                    const SizedBox(height: 30),
                    Text(
                      "Attached Files",
                      style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: primaryText),
                    ),
                    const SizedBox(height: 10),
                    ...entry.fileNames.map((fileName) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.doc_text, color: primaryText, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              fileName,
                              style: TextStyle(fontSize: 13, color: primaryText),
                            ),
                          ),
                          Icon(CupertinoIcons.cloud_download, color: secondaryText, size: 18),
                        ],
                      ),
                    )),
                  ],
                ],
              ),
            ),
          ),
          
          // Floating Top navigation bar
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
          
          // Premium action bar
          Positioned(
            bottom: 24,
            left: 60,
            right: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Edit button
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Editing reflection..."),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black.withOpacity(0.06)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: const Icon(
                      CupertinoIcons.pencil,
                      color: Color(0xFF2C2A29),
                      size: 18,
                    ),
                  ),
                ),
                // Share button
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Preparing share layout..."),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black.withOpacity(0.06)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: const Icon(
                      CupertinoIcons.share,
                      color: Color(0xFF2C2A29),
                      size: 18,
                    ),
                  ),
                ),
                // Delete button
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black.withOpacity(0.06)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: const Icon(
                      CupertinoIcons.trash,
                      color: Color(0xFF784136),
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
