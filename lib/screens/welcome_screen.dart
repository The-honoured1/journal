import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _customPicController = TextEditingController();

  final List<String> avatarPresets = [
    'https://images.unsplash.com/photo-1513836279014-a89f7a76ae86?w=150&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=150&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1502082553048-f009c37129b9?w=150&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1534088568595-a066f410bcda?w=150&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=150&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1517256064527-09c53b2d0bc6?w=150&auto=format&fit=crop&q=80',
  ];

  late String selectedAvatarUrl;

  @override
  void initState() {
    super.initState();
    selectedAvatarUrl = avatarPresets.first;
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

    // Midnight Ink palette
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
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 48),

              // ── App Icon ────────────────────────────────────────────────
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent, accent.withOpacity(0.6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.auto_stories_rounded, size: 38, color: Colors.white),
              ),

              const SizedBox(height: 28),

              // ── Title ────────────────────────────────────────────────────
              Text(
                "Journal",
                style: GoogleFonts.outfit(
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  color: priText,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Your quiet space for reflection,\nmood tracking & memory keeping.",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: secText,
                  height: 1.55,
                ),
              ),

              const SizedBox(height: 48),

              // ── Setup Card ───────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name label
                    Text(
                      "WHAT'S YOUR NAME?",
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: secText,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameController,
                      style: GoogleFonts.outfit(color: priText, fontWeight: FontWeight.w600, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: "Enter your name...",
                        hintStyle: GoogleFonts.outfit(color: secText),
                        filled: true,
                        fillColor: fillBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: accent, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 32),

                    // Avatar label
                    Text(
                      "CHOOSE YOUR AVATAR",
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: secText,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 72,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: avatarPresets.length,
                        itemBuilder: (context, idx) {
                          final avatar = avatarPresets[idx];
                          final isSelected = selectedAvatarUrl == avatar;
                          return GestureDetector(
                            onTap: () => setState(() {
                              selectedAvatarUrl = avatar;
                              _customPicController.clear();
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 62,
                              height: 62,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? accent : Colors.transparent,
                                  width: 3,
                                ),
                                boxShadow: isSelected
                                    ? [BoxShadow(color: accent.withOpacity(0.3), blurRadius: 10)]
                                    : null,
                                image: DecorationImage(image: NetworkImage(avatar), fit: BoxFit.cover),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      "Or paste a custom image URL",
                      style: GoogleFonts.outfit(fontSize: 12, color: secText, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _customPicController,
                      style: GoogleFonts.outfit(color: priText, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: "https://example.com/avatar.jpg",
                        hintStyle: GoogleFonts.outfit(color: secText, fontSize: 13),
                        filled: true,
                        fillColor: fillBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: accent, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      ),
                      onChanged: (val) {
                        if (val.trim().isNotEmpty) {
                          setState(() => selectedAvatarUrl = val.trim());
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── CTA Button ───────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 58,
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
                    style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
