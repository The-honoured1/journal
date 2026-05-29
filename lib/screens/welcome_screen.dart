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
    'https://images.unsplash.com/photo-1513836279014-a89f7a76ae86?w=150&auto=format&fit=crop&q=80', // Fox / Deer
    'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=150&auto=format&fit=crop&q=80', // Cat
    'https://images.unsplash.com/photo-1502082553048-f009c37129b9?w=150&auto=format&fit=crop&q=80', // Tree
    'https://images.unsplash.com/photo-1534088568595-a066f410bcda?w=150&auto=format&fit=crop&q=80', // Blue sky
    'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=150&auto=format&fit=crop&q=80', // Mountain
    'https://images.unsplash.com/photo-1517256064527-09c53b2d0bc6?w=150&auto=format&fit=crop&q=80', // Tea
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
    final primaryColor = const Color(0xFFFFB534); // Warm amber
    final scaffoldBg = isDark ? const Color(0xFF141311) : const Color(0xFFF5F5F2);
    final cardBg = isDark ? const Color(0xFF22201D) : Colors.white;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              
              // App Logo / Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.auto_stories,
                    size: 38,
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Title
              Text(
                "Journal",
                style: GoogleFonts.outfit(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFFECE7E2) : const Color(0xFF2C2A29),
                ),
              ),
              const SizedBox(height: 8),
              
              // Subtitle
              Text(
                "Your quiet, warm space for reflection, mood tracking, and memory keeping.",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: isDark ? const Color(0xFF9E9992) : const Color(0xFF7C7975),
                  height: 1.4,
                ),
              ),
              
              const SizedBox(height: 40),

              // Name Entry Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "What is your name?",
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFECE7E2) : const Color(0xFF2C2A29),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: "Enter your name...",
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: isDark ? Colors.black12 : const Color(0xFFF7F5F2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      style: TextStyle(
                        color: isDark ? const Color(0xFFECE7E2) : const Color(0xFF2C2A29),
                        fontWeight: FontWeight.bold,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Avatar Selection Title
                    Text(
                      "Select a Profile Icon",
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFECE7E2) : const Color(0xFF2C2A29),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Avatar Row
                    SizedBox(
                      height: 70,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: avatarPresets.length,
                        itemBuilder: (context, idx) {
                          final avatar = avatarPresets[idx];
                          final isSelected = selectedAvatarUrl == avatar;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedAvatarUrl = avatar;
                                _customPicController.clear();
                              });
                            },
                            child: Container(
                              width: 60,
                              height: 60,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? primaryColor : Colors.transparent,
                                  width: 3,
                                ),
                                image: DecorationImage(
                                  image: NetworkImage(avatar),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Custom Profile Pic URL option
                    Text(
                      "Or paste a custom image URL:",
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _customPicController,
                      decoration: InputDecoration(
                        hintText: "https://example.com/avatar.jpg",
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                        filled: true,
                        fillColor: isDark ? Colors.black12 : const Color(0xFFF7F5F2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      style: TextStyle(
                        color: isDark ? const Color(0xFFECE7E2) : const Color(0xFF2C2A29),
                        fontSize: 13,
                      ),
                      onChanged: (val) {
                        if (val.trim().isNotEmpty) {
                          setState(() {
                            selectedAvatarUrl = val.trim();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 36),
              
              // Begin Button
              SizedBox(
                width: double.infinity,
                height: 54,
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
                    backgroundColor: primaryColor,
                    foregroundColor: const Color(0xFF2C2A29),
                    disabledBackgroundColor: isDark ? Colors.white10 : Colors.black12,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                  ),
                  child: Text(
                    "Begin Journey",
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
