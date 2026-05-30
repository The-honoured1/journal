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
    
    // Spacious, styled design tokens
    final scaffoldBg = isDark ? const Color(0xFF0C100D) : const Color(0xFFF9F7F3);
    final accentColor = isDark ? const Color(0xFF6A9978) : const Color(0xFF2C5E43);

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
              padding: const EdgeInsets.only(left: 24, right: 24, top: 90, bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date
                  Center(
                    child: Text(
                      entry.date.toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Title
                  Center(
                    child: Text(
                      entry.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: primaryText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Category pills
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: entry.categories.map((category) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: accentColor.withOpacity(0.25),
                          ),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),
                  
                  // Render Images if attached, else default ambient placeholder
                  if (hasImages)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: SizedBox(
                        height: 240,
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
                        height: 200,
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
                  
                  const SizedBox(height: 24),
                  
                  // Audio player if voice note exists
                  if (hasAudio) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.01),
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
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: accentColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                CupertinoIcons.play_fill,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SizedBox(
                              height: 38,
                              child: AudioWaveform(
                                progress: playbackProgress,
                                isPlaying: isPlaying,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
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
                    const SizedBox(height: 28),
                  ],
                  
                  // Reflection Text
                  Text(
                    entry.text,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      height: 1.7,
                      color: primaryText.withOpacity(0.85),
                    ),
                  ),
                  
                  // File attachments list
                  if (hasFiles) ...[
                    const SizedBox(height: 36),
                    Text(
                      "Attached Files",
                      style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: primaryText),
                    ),
                    const SizedBox(height: 12),
                    ...entry.fileNames.map((fileName) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.doc, color: primaryText, size: 20),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              fileName,
                              style: TextStyle(fontSize: 14, color: primaryText),
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
              padding: const EdgeInsets.only(left: 20, right: 20, top: 40, bottom: 12),
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
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: cardBg,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
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
                    "Reflection details",
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: secondaryText,
                    ),
                  ),
                  const SizedBox(width: 40), // spacer balance
                ],
              ),
            ),
          ),
          
          // Premium action bar
          Positioned(
            bottom: 30,
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
                    width: 50,
                    height: 50,
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
                      color: Color(0xFF1A1F1C),
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
                    width: 50,
                    height: 50,
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
                      color: Color(0xFF1A1F1C),
                      size: 18,
                    ),
                  ),
                ),
                // Delete button
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    width: 50,
                    height: 50,
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
                      color: Colors.redAccent,
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
