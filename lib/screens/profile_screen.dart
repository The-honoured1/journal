import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/security_provider.dart';

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
              widget.isDark ? const Color(0xFF181F1B) : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
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
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(color: widget.primaryText),
              ),
              const SizedBox(height: 16),
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
                    borderRadius: BorderRadius.circular(16),
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
                if (mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A9978),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Save",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // Spacious passcode creation modal/dialog
  void _setupPasscodeDialog(BuildContext context) {
    final List<String> pinList = [];
    final stateSetter = StateProvider<List<String>>((ref) => []);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final activePin = ref.watch(stateSetter);
            
            return AlertDialog(
              backgroundColor: widget.isDark ? const Color(0xFF181F1B) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              title: Center(
                child: Text(
                  "Set Passcode",
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: widget.primaryText,
                  ),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Create a 4-digit passcode to protect your journal.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: widget.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Indicator dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      final isActive = index < activePin.length;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: isActive
                              ? (widget.isDark ? const Color(0xFF6A9978) : const Color(0xFF2C5E43))
                              : Colors.grey.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),
                  
                  // Keypad grid
                  Container(
                    constraints: const BoxConstraints(maxWidth: 240),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: ['1', '2', '3'].map((k) => _buildDialogKey(k, ref, stateSetter)).toList(),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: ['4', '5', '6'].map((k) => _buildDialogKey(k, ref, stateSetter)).toList(),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: ['7', '8', '9'].map((k) => _buildDialogKey(k, ref, stateSetter)).toList(),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const SizedBox(width: 50, height: 50),
                            _buildDialogKey('0', ref, stateSetter),
                            _buildDialogKey('back', ref, stateSetter),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cancel", style: TextStyle(color: widget.secondaryText)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDialogKey(String key, WidgetRef ref, StateProvider<List<String>> stateSetter) {
    final isBack = key == 'back';
    final activePin = ref.read(stateSetter);
    final keyBg = widget.isDark ? const Color(0xFF232B26) : const Color(0xFFECEFEA);
    
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: keyBg,
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            final current = List<String>.from(activePin);
            if (isBack) {
              if (current.isNotEmpty) {
                current.removeLast();
                ref.read(stateSetter.notifier).state = current;
              }
            } else {
              if (current.length < 4) {
                current.add(key);
                ref.read(stateSetter.notifier).state = current;
                
                if (current.length == 4) {
                  // Enable security
                  this.ref.read(securityProvider.notifier).enablePassword(current.join());
                  HapticFeedback.mediumImpact();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Secure passcode set successfully"),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            }
          },
          customBorder: const CircleBorder(),
          child: Center(
            child: isBack
                ? Icon(CupertinoIcons.delete_left, color: widget.primaryText, size: 16)
                : Text(
                    key,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: widget.primaryText,
                    ),
                  ),
          ),
        ),
      ),
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
    final securityState = ref.watch(securityProvider);
    
    final backgroundColor =
        widget.isDark ? const Color(0xFF0C100D) : const Color(0xFFF9F7F3);
    final accentColor = widget.isDark ? const Color(0xFF6A9978) : const Color(0xFF2C5E43);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 36),

            // ── Profile Card ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(28),
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
                          width: 80,
                          height: 80,
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
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(CupertinoIcons.pencil,
                                size: 11,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: widget.primaryText,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Reflecting daily",
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: widget.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Stats Row ─────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: "Streak",
                    metric:
                        widget.entryCount > 0 ? "${widget.entryCount} days" : "0 days",
                    icon: CupertinoIcons.flame_fill,
                    color: const Color(0xFFD4A373),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    title: "Entries",
                    metric: "${widget.entryCount}",
                    icon: CupertinoIcons.book_fill,
                    color: accentColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── Security Settings Section (Password, Fingerprint, Face ID) ──
            Text(
              "Security Settings",
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.primaryText,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: widget.cardBg,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    leading: Icon(
                      CupertinoIcons.lock_shield,
                      color: accentColor,
                    ),
                    title: Text(
                      "Require Passcode Lock",
                      style: GoogleFonts.outfit(
                          color: widget.primaryText,
                          fontWeight: FontWeight.w600),
                    ),
                    trailing: Switch(
                      value: securityState.isPasswordEnabled,
                      activeColor: accentColor,
                      onChanged: (val) {
                        if (val) {
                          _setupPasscodeDialog(context);
                        } else {
                          ref.read(securityProvider.notifier).disablePassword();
                        }
                      },
                    ),
                  ),
                  if (securityState.isPasswordEnabled) ...[
                    const Divider(height: 1, indent: 56, endIndent: 20),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      leading: Icon(
                        CupertinoIcons.device_phone_portrait,
                        color: accentColor,
                      ),
                      title: Text(
                        "Fingerprint Unlock",
                        style: GoogleFonts.outfit(
                            color: widget.primaryText,
                            fontWeight: FontWeight.w500),
                      ),
                      trailing: Switch(
                        value: securityState.isFingerprintEnabled,
                        activeColor: accentColor,
                        onChanged: (val) {
                          ref.read(securityProvider.notifier).setFingerprintEnabled(val);
                        },
                      ),
                    ),
                    const Divider(height: 1, indent: 56, endIndent: 20),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      leading: Icon(
                        CupertinoIcons.viewfinder,
                        color: accentColor,
                      ),
                      title: Text(
                        "Face ID Unlock",
                        style: GoogleFonts.outfit(
                            color: widget.primaryText,
                            fontWeight: FontWeight.w500),
                      ),
                      trailing: Switch(
                        value: securityState.isFaceEnabled,
                        activeColor: accentColor,
                        onChanged: (val) {
                          ref.read(securityProvider.notifier).setFaceEnabled(val);
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── App Settings Card ─────────────────────────────────────
            Text(
              "Preferences",
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.primaryText,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: widget.cardBg,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    leading: Icon(
                      widget.isDark
                          ? CupertinoIcons.sun_max
                          : CupertinoIcons.moon,
                      color: accentColor,
                    ),
                    title: Text(
                      "Dark Mode",
                      style: GoogleFonts.outfit(
                          color: widget.primaryText,
                          fontWeight: FontWeight.w600),
                    ),
                    trailing: Switch(
                      value: widget.isDark,
                      activeColor: accentColor,
                      onChanged: (_) =>
                          ref.read(themeProvider.notifier).toggleTheme(),
                    ),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 20),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    leading:
                        Icon(CupertinoIcons.info, color: widget.secondaryText),
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
                  const Divider(height: 1, indent: 56, endIndent: 20),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    leading:
                        const Icon(CupertinoIcons.square_arrow_right, color: Colors.redAccent),
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
            const SizedBox(height: 32),

            // ── "Find me here" section ────────────────────────────
            Text(
              "Find me here",
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.primaryText,
              ),
            ),
            const SizedBox(height: 16),

            // Telegram
            _buildLinkButton(
              icon: CupertinoIcons.paperplane,
              label: "Telegram",
              sublabel: "@Th3_honoured1nd",
              color: const Color(0xFF0088CC),
              onTap: () => _launchUrl("https://t.me/Th3_honoured1nd"),
            ),
            const SizedBox(height: 14),

            // Email
            _buildLinkButton(
              icon: CupertinoIcons.mail,
              label: "Email",
              sublabel: "christian4onos@gmail.com",
              color: const Color(0xFFD44638),
              onTap: () =>
                  _launchUrl("mailto:christian4onos@gmail.com"),
            ),
            const SizedBox(height: 14),

            // GitHub
            _buildLinkButton(
              icon: CupertinoIcons.square_arrow_up,
              label: "GitHub",
              sublabel: "The-honoured1",
              color: widget.isDark
                  ? const Color(0xFFB0C4B8)
                  : const Color(0xFF2C5E43),
              onTap: () =>
                  _launchUrl("https://github.com/The-honoured1"),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String metric,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: widget.cardBg,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
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
                const SizedBox(height: 2),
                Text(
                  title,
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
    );
  }

  Widget _buildLinkButton({
    required IconData icon,
    required String label,
    required String sublabel,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        splashColor: color.withOpacity(0.15),
        highlightColor: color.withOpacity(0.08),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: widget.cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withOpacity(0.25), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(icon, color: color, size: 22),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: widget.primaryText,
                      ),
                    ),
                    const SizedBox(height: 3),
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
                CupertinoIcons.arrow_up_right_square,
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
