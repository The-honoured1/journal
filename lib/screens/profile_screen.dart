import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class ProfileScreen extends ConsumerWidget {
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

  void _showEditProfileDialog(BuildContext context, WidgetRef ref, String currentName, String currentPic) {
    final nameController = TextEditingController(text: currentName);
    final picController = TextEditingController(text: currentPic);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF282522) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            "Edit Profile",
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: primaryText,
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
                  fillColor: isDark ? Colors.black12 : const Color(0xFFF7F5F2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(color: primaryText),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: picController,
                decoration: InputDecoration(
                  labelText: "Profile Picture URL",
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: isDark ? Colors.black12 : const Color(0xFFF7F5F2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(color: primaryText, fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Save", style: TextStyle(color: Color(0xFF2C2A29), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final backgroundColor = isDark ? const Color(0xFF1E1A1A) : Colors.white;
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
            color: primaryText,
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
            
            // Profile Card (Name + Avatar)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(
                          user.profilePicUrl ?? 'https://images.unsplash.com/photo-1513836279014-a89f7a76ae86?w=150&auto=format&fit=crop&q=80',
                        ),
                        fit: BoxFit.cover,
                      ),
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
                            color: primaryText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Reflecting daily",
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit_outlined, color: accentColor, size: 22),
                    onPressed: () => _showEditProfileDialog(
                      context,
                      ref,
                      user.name,
                      user.profilePicUrl ?? '',
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Streak and Entry Statistics Cards
            Row(
              children: [
                Expanded(
                  child: _buildStreakCard(
                    title: "Reflection Streak",
                    metric: entryCount > 0 ? "$entryCount Days" : "0 Days",
                    icon: CupertinoIcons.flame_fill,
                    color: const Color(0xFFFFB534),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildStreakCard(
                    title: "Total Entries",
                    metric: "$entryCount logged",
                    icon: CupertinoIcons.book_fill,
                    color: const Color(0xFF8BA64F),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // App settings controls card
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  // Dark mode switcher
                  ListTile(
                    leading: Icon(
                      isDark ? Icons.brightness_2 : Icons.brightness_5,
                      color: accentColor,
                    ),
                    title: Text(
                      "Dark Mode",
                      style: GoogleFonts.outfit(color: primaryText, fontWeight: FontWeight.w500),
                    ),
                    trailing: Switch(
                      value: isDark,
                      activeColor: accentColor,
                      onChanged: (val) {
                        ref.read(themeProvider.notifier).toggleTheme();
                      },
                    ),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  
                  // App state information
                  ListTile(
                    leading: Icon(Icons.info_outline, color: secondaryText),
                    title: Text(
                      "Version Info",
                      style: GoogleFonts.outfit(color: primaryText, fontWeight: FontWeight.w500),
                    ),
                    trailing: Text(
                      "1.0.0 (Ad-Free & Private)",
                      style: GoogleFonts.outfit(color: secondaryText, fontSize: 13),
                    ),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  
                  // Logout Button
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.redAccent),
                    title: Text(
                      "Log Out",
                      style: GoogleFonts.outfit(color: Colors.redAccent, fontWeight: FontWeight.bold),
                    ),
                    onTap: () async {
                      await ref.read(authProvider.notifier).logout();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard({
    required String title,
    required String metric,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
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
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: secondaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            metric,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryText,
            ),
          ),
        ],
      ),
    );
  }
}
