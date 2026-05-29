import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final bool isDark;
  final Color primaryText;
  final Color secondaryText;
  final Color cardBg;
  final int entryCount;

  const ProfileScreen({
    super.key,
    required this.isDark,
    required this.primaryText,
    required this.secondaryText,
    required this.cardBg,
    required this.entryCount,
  });

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _bounceController.forward();
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _showEditProfileDialog(
      BuildContext context, String currentName, String currentPic) {
    final nameController = TextEditingController(text: currentName);
    final picController = TextEditingController(text: currentPic);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              widget.isDark ? const Color(0xFF282522) : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            "Edit Profile",
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: widget.primaryText,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Your Name",
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: widget.isDark
                      ? Colors.black12
                      : const Color(0xFFF7F5F2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(color: widget.primaryText),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: picController,
                decoration: InputDecoration(
                  labelText: "Profile Picture URL",
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: widget.isDark
                      ? Colors.black12
                      : const Color(0xFFF7F5F2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style:
                    TextStyle(color: widget.primaryText, fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isNotEmpty) {
                  await ref.read(authProvider.notifier).updateProfileNameAndPic(
                        nameController.text.trim(),
                        picController.text.trim(),
                      );
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB534),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Save",
                  style: TextStyle(
                      color: Color(0xFF2C2A29),
                      fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Couldn't open $url"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final backgroundColor =
        widget.isDark ? const Color(0xFF1E1A1A) : Colors.white;
    final accentColor = const Color(0xFFFFB534);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'My Profile',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: widget.primaryText,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ── Profile Card ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: widget.cardBg,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _showEditProfileDialog(
                        context, user.name, user.profilePicUrl ?? ''),
                    child: Stack(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: accentColor, width: 2.5),
                            image: DecorationImage(
                              image: NetworkImage(
                                user.profilePicUrl ??
                                    'https://images.unsplash.com/photo-1513836279014-a89f7a76ae86?w=150&auto=format&fit=crop&q=80',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit,
                                size: 10,
                                color: Color(0xFF2C2A29)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: widget.primaryText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Reflecting daily ✨",
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: widget.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Stats Row ─────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: "Streak",
                    metric:
                        widget.entryCount > 0 ? "${widget.entryCount}d" : "0d",
                    emoji: "🔥",
                    color: const Color(0xFFFFB534),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildStatCard(
                    title: "Entries",
                    metric: "${widget.entryCount}",
                    emoji: "📖",
                    color: const Color(0xFF8BA64F),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Settings Card ─────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: widget.cardBg,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      widget.isDark
                          ? Icons.brightness_2
                          : Icons.brightness_5,
                      color: accentColor,
                    ),
                    title: Text(
                      "Dark Mode",
                      style: GoogleFonts.outfit(
                          color: widget.primaryText,
                          fontWeight: FontWeight.w500),
                    ),
                    trailing: Switch(
                      value: widget.isDark,
                      activeColor: accentColor,
                      onChanged: (_) =>
                          ref.read(themeProvider.notifier).toggleTheme(),
                    ),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  ListTile(
                    leading:
                        Icon(Icons.info_outline, color: widget.secondaryText),
                    title: Text(
                      "Version",
                      style: GoogleFonts.outfit(
                          color: widget.primaryText,
                          fontWeight: FontWeight.w500),
                    ),
                    trailing: Text(
                      "1.0.0 · Ad-Free",
                      style: GoogleFonts.outfit(
                          color: widget.secondaryText, fontSize: 13),
                    ),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  ListTile(
                    leading:
                        const Icon(Icons.logout, color: Colors.redAccent),
                    title: Text(
                      "Log Out",
                      style: GoogleFonts.outfit(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold),
                    ),
                    onTap: () async {
                      await ref.read(authProvider.notifier).logout();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── "Find me here" section ────────────────────────────
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Find me here 👋",
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: widget.primaryText,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Telegram
            _buildLinkButton(
              emoji: "✈️",
              label: "Telegram",
              sublabel: "@Th3_honoured1nd",
              color: const Color(0xFF0088CC),
              onTap: () => _launchUrl("https://t.me/Th3_honoured1nd"),
            ),
            const SizedBox(height: 12),

            // Email
            _buildLinkButton(
              emoji: "📬",
              label: "Email",
              sublabel: "christian4onos@gmail.com",
              color: const Color(0xFFD44638),
              onTap: () =>
                  _launchUrl("mailto:christian4onos@gmail.com"),
            ),
            const SizedBox(height: 12),

            // GitHub
            _buildLinkButton(
              emoji: "🐙",
              label: "GitHub",
              sublabel: "The-honoured1",
              color: widget.isDark
                  ? const Color(0xFFCCCCCC)
                  : const Color(0xFF333333),
              onTap: () =>
                  _launchUrl("https://github.com/The-honoured1"),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String metric,
    required String emoji,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: widget.cardBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                metric,
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: widget.primaryText,
                ),
              ),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: widget.secondaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLinkButton({
    required String emoji,
    required String label,
    required String sublabel,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: color.withOpacity(0.15),
        highlightColor: color.withOpacity(0.08),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: widget.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.25), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(emoji,
                      style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: widget.primaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sublabel,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                CupertinoIcons.arrow_up_right_square_fill,
                color: color.withOpacity(0.6),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
