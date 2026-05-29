import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthorScreen extends StatelessWidget {
  final bool isDark;
  final Color primaryText;
  final Color secondaryText;
  final Color cardBg;

  const AuthorScreen({
    super.key,
    required this.isDark,
    required this.primaryText,
    required this.secondaryText,
    required this.cardBg,
  });

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "$label copied to clipboard!",
          style: const TextStyle(color: Color(0xFF2C2A29), fontWeight: FontWeight.bold),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFFFB534),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDark ? const Color(0xFF1E1A1A) : Colors.white;
    final accentColor = const Color(0xFFFFB534);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'About the Author',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            
            // Warm Ambient illustration of the creator/author's space
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                image: const DecorationImage(
                  image: NetworkImage(
                    "https://images.unsplash.com/photo-1517256064527-09c53b2d0bc6?w=600&auto=format&fit=crop&q=80",
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Author Name/Title
            Text(
              "Hi, I'm the Creator 👋",
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Developer & Mindfulness Advocate",
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: accentColor,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Core Message Box
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: accentColor.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    "Why I Built This App",
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "I believe that writing down your thoughts, capturing daily memories, and keeping track of your emotional patterns should be a peaceful, therapeutic routine—not a source of notification noise or subscription fatigue.\n\n"
                    "This app is built to be a calm sanctuary: a quiet diary for your thoughts, completely free from ads, subscription gates, or trackings. Your entries, images, and voice notes are stored safely right on your device.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: secondaryText,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Key Pillars
            _buildPillarTile(
              icon: CupertinoIcons.shield_fill,
              title: "100% Private & Offline-First",
              description: "Your daily logs, uploaded photos, and voice notes stay locally on your device. None of your personal thoughts ever touch a third-party server.",
              color: const Color(0xFF8BA64F),
            ),
            const SizedBox(height: 14),
            _buildPillarTile(
              icon: CupertinoIcons.gift_fill,
              title: "Completely Free",
              description: "Every single feature—from monthly calendar views to rich voice recordings and memory flashbacks—is fully unlocked. No paywalls.",
              color: accentColor,
            ),
            const SizedBox(height: 14),
            _buildPillarTile(
              icon: CupertinoIcons.xmark_shield_fill,
              title: "Zero Advertising or Tracking",
              description: "No banner ads, no video popups, and no analytical trackers. Just you and your thoughts in a beautifully warm, minimalist space.",
              color: const Color(0xFF7A7C75),
            ),
            
            const SizedBox(height: 32),
            
            // Get in Touch section
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  "Get in Touch 💬",
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryText,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Contact Buttons
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  _buildContactTile(
                    context: context,
                    icon: CupertinoIcons.paperplane_fill,
                    title: "Telegram (Preferred)",
                    value: "@Th3_honoured1nd",
                    copyText: "https://t.me/Th3_honoured1nd",
                    description: "Best way to reach me — bugs, feedback, collabs, or hiring for your next project",
                    color: const Color(0xFF0088cc),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _buildContactTile(
                    context: context,
                    icon: Icons.email,
                    title: "Email",
                    value: "christian4onos@gmail.com",
                    copyText: "christian4onos@gmail.com",
                    description: "Send bug reports, project proposals, or business inquiries here",
                    color: const Color(0xFFD44638),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _buildContactTile(
                    context: context,
                    icon: CupertinoIcons.hand_point_right_fill,
                    title: "GitHub Portfolio",
                    value: "The-honoured1",
                    copyText: "https://github.com/The-honoured1",
                    description: "Browse my open-source work and other apps I've built",
                    color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF333333),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Handcrafted Signoff
            Text(
              "Handcrafted with care 🌿",
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: secondaryText,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildPillarTile({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: secondaryText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required String copyText,
    required String description,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: primaryText,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              "Copy",
              style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: GoogleFonts.outfit(
              color: secondaryText,
              fontSize: 10,
            ),
          ),
        ],
      ),
      onTap: () => _copyToClipboard(context, copyText, title),
    );
  }
}
