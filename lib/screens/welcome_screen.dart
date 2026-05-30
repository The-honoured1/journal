import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _customPicController = TextEditingController();

  XFile? _pickedImage;
  String selectedAvatarUrl = '';
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    selectedAvatarUrl = '';
  }
  
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = image;
        selectedAvatarUrl = image.path;
        _customPicController.clear();
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _customPicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Premium glowing colors (Midnight Ink theme but enhanced)
    final bg      = isDark ? const Color(0xFF0E0C1A) : const Color(0xFFF5F0E8);
    final cardBg  = isDark ? const Color(0xFF1E1A35) : const Color(0xFFFFFDF8);
    final border  = isDark ? const Color(0xFF2E2A4A) : const Color(0xFFE8DFD0);
    final accent  = isDark ? const Color(0xFF9B7FE8) : const Color(0xFF3D2B8E);
    final amber   = isDark ? const Color(0xFFF0A057) : const Color(0xFFE07B3C);
    final priText = isDark ? const Color(0xFFEDE8FF) : const Color(0xFF1A1628);
    final secText = isDark ? const Color(0xFF8880A8) : const Color(0xFF6B6282);
    final fillBg  = isDark ? const Color(0xFF201C38) : const Color(0xFFF0EBE0);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // ── Background Glowing Blobs (Dynamic Visuals) ────────────────────
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withOpacity(isDark ? 0.22 : 0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: amber.withOpacity(isDark ? 0.18 : 0.12),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            right: -100,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withOpacity(isDark ? 0.12 : 0.08),
              ),
            ),
          ),
          // Blur layer for background blobs
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
              child: Container(color: Colors.transparent),
            ),
          ),

          // ── Scrollable Content ───────────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    // App Icon with glass decoration
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [accent, accent.withOpacity(0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withOpacity(0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.auto_stories_rounded, size: 38, color: Colors.white),
                    ),

                    const SizedBox(height: 20),

                    // Title
                    Text(
                      "Journal",
                      style: GoogleFonts.outfit(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: priText,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Your quiet space for reflection,\nmood tracking & memory keeping.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        color: secText,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Setup Card (Glassmorphism design)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: cardBg.withOpacity(isDark ? 0.65 : 0.8),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name field label
                              Text(
                                "WHAT'S YOUR NAME?",
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: secText,
                                  letterSpacing: 1.6,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _nameController,
                                style: GoogleFonts.outfit(
                                  color: priText,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  hintText: "Enter your name...",
                                  hintStyle: GoogleFonts.outfit(color: secText.withOpacity(0.7)),
                                  filled: true,
                                  fillColor: fillBg.withOpacity(isDark ? 0.6 : 0.8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: accent, width: 1.8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                ),
                                onChanged: (_) => setState(() {}),
                              ),

                              const SizedBox(height: 28),

                              // Avatar selection section
                              Text(
                                "CHOOSE YOUR AVATAR",
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: secText,
                                  letterSpacing: 1.6,
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Interactive Circle Avatar Picker
                              Center(
                                child: GestureDetector(
                                  onTap: _pickImage,
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 300),
                                          width: 96,
                                          height: 96,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: SweepGradient(
                                              colors: [accent, amber, accent],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: accent.withOpacity(0.3),
                                                blurRadius: 16,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                          padding: const EdgeInsets.all(3),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: fillBg,
                                            ),
                                            child: ClipOval(
                                              child: _pickedImage != null
                                                  ? (kIsWeb
                                                      ? Image.network(
                                                          _pickedImage!.path,
                                                          width: 90,
                                                          height: 90,
                                                          fit: BoxFit.cover,
                                                        )
                                                      : Image.file(
                                                          File(_pickedImage!.path),
                                                          width: 90,
                                                          height: 90,
                                                          fit: BoxFit.cover,
                                                        ))
                                                  : (selectedAvatarUrl.isNotEmpty
                                                      ? Image.network(
                                                          selectedAvatarUrl,
                                                          width: 90,
                                                          height: 90,
                                                          fit: BoxFit.cover,
                                                        )
                                                      : Icon(
                                                          CupertinoIcons.camera_fill,
                                                          size: 32,
                                                          color: secText.withOpacity(0.8),
                                                        )),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: amber,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.2),
                                                  blurRadius: 6,
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              CupertinoIcons.photo_on_rectangle,
                                              size: 13,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Custom image URL paste section
                              Text(
                                "Or paste a custom image URL",
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: secText,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _customPicController,
                                style: GoogleFonts.outfit(
                                  color: priText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  hintText: "https://example.com/avatar.jpg",
                                  hintStyle: GoogleFonts.outfit(color: secText.withOpacity(0.5)),
                                  filled: true,
                                  fillColor: fillBg.withOpacity(isDark ? 0.6 : 0.8),
                                  prefixIcon: Icon(CupertinoIcons.link, color: secText.withOpacity(0.7), size: 16),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(color: accent, width: 1.5),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    selectedAvatarUrl = val.trim();
                                    if (val.trim().isNotEmpty) {
                                      _pickedImage = null;
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // CTA Button with glow
                    Container(
                      width: double.infinity,
                      height: 58,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: _nameController.text.trim().isEmpty
                            ? []
                            : [
                                BoxShadow(
                                  color: amber.withOpacity(0.35),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                      ),
                      child: ElevatedButton(
                        onPressed: _nameController.text.trim().isEmpty
                            ? null
                            : () async {
                                final name = _nameController.text.trim();
                                await ref.read(authProvider.notifier).register(
                                      name,
                                      "${name.toLowerCase().replaceAll(' ', '')}@journal.com",
                                      selectedAvatarUrl,
                                    );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: amber,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: isDark ? Colors.white10 : Colors.black12,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        ),
                        child: Text(
                          "Begin Journey",
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
