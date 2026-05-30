import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/security_provider.dart';

// ─── Color tokens ──────────────────────────────────────────────────────────
const _darkBg       = Color(0xFF0E0C1A);
const _darkCard     = Color(0xFF1E1A35);
const _darkBorder   = Color(0xFF2E2A4A);
const _violet       = Color(0xFF9B7FE8);
const _deepViolet   = Color(0xFF3D2B8E);
const _amber        = Color(0xFFF0A057);
const _lightBg      = Color(0xFFF5F0E8);
const _lightCard    = Color(0xFFFFFDF8);
const _lightBorder  = Color(0xFFE8DFD0);

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

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Color get accent => widget.isDark ? _violet : _deepViolet;
  Color get amberAccent => widget.isDark ? _amber : const Color(0xFFE07B3C);
  Color get bg => widget.isDark ? _darkBg : _lightBg;
  Color get cardBorder => widget.isDark ? _darkBorder : _lightBorder;

  // ── Edit Profile ──────────────────────────────────────────────────────────
  void _showEditProfileDialog(BuildContext context, String currentName, String currentPic) {
    final nameController = TextEditingController(text: currentName);
    final picController  = TextEditingController(text: currentPic);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.isDark ? _darkCard : _lightCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(
          "Edit Profile",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: widget.primaryText),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogField(nameController, "Your Name", widget.primaryText),
            const SizedBox(height: 16),
            _dialogField(picController, "Profile Picture URL", widget.primaryText, fontSize: 13),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: widget.secondaryText)),
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
              backgroundColor: accent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text("Save", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(TextEditingController c, String label, Color textColor, {double fontSize = 15}) {
    return TextField(
      controller: c,
      style: TextStyle(color: textColor, fontSize: fontSize),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: widget.secondaryText, fontSize: 13),
        filled: true,
        fillColor: widget.isDark ? const Color(0xFF201C38) : const Color(0xFFF0EBE0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
      ),
    );
  }

  // ── Passcode setup ─────────────────────────────────────────────────────────
  void _setupPasscodeDialog(BuildContext context) {
    final stateSetter = StateProvider<List<String>>((ref) => []);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final activePin = ref.watch(stateSetter);
          return AlertDialog(
            backgroundColor: widget.isDark ? _darkCard : _lightCard,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            title: Center(
              child: Text(
                "Set Passcode",
                style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: widget.primaryText),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Create a 4-digit passcode to protect your journal.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(fontSize: 13, color: widget.secondaryText),
                ),
                const SizedBox(height: 32),
                // Indicator dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: 14, height: 14,
                      decoration: BoxDecoration(
                        color: i < activePin.length ? accent : widget.secondaryText.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 36),
                // Keypad
                Container(
                  constraints: const BoxConstraints(maxWidth: 240),
                  child: Column(
                    children: [
                      _pinRow(['1','2','3'], ref, stateSetter),
                      const SizedBox(height: 14),
                      _pinRow(['4','5','6'], ref, stateSetter),
                      const SizedBox(height: 14),
                      _pinRow(['7','8','9'], ref, stateSetter),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const SizedBox(width: 54, height: 54),
                          _buildDialogKey('0', ref, stateSetter),
                          _buildDialogKey('back', ref, stateSetter),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel", style: TextStyle(color: widget.secondaryText)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Row _pinRow(List<String> keys, WidgetRef r, StateProvider<List<String>> s) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((k) => _buildDialogKey(k, r, s)).toList(),
    );
  }

  Widget _buildDialogKey(String key, WidgetRef r, StateProvider<List<String>> s) {
    final isBack = key == 'back';
    return Container(
      width: 54, height: 54,
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF2A2445) : const Color(0xFFEDE8FF),
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            final current = List<String>.from(r.read(s));
            if (isBack) {
              if (current.isNotEmpty) { current.removeLast(); r.read(s.notifier).state = current; }
            } else {
              if (current.length < 4) {
                current.add(key);
                r.read(s.notifier).state = current;
                if (current.length == 4) {
                  this.ref.read(securityProvider.notifier).enablePassword(current.join());
                  HapticFeedback.mediumImpact();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Secure passcode set successfully")),
                  );
                }
              }
            }
          },
          customBorder: const CircleBorder(),
          child: Center(
            child: isBack
                ? Icon(CupertinoIcons.delete_left, color: widget.primaryText, size: 18)
                : Text(key, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600, color: widget.primaryText)),
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Couldn't open $url")));
    }
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final user          = ref.watch(authProvider);
    final securityState = ref.watch(securityProvider);

    return Scaffold(
      backgroundColor: bg,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),

            // ── Profile Hero Card ────────────────────────────────────────
            _buildProfileHero(user),

            const SizedBox(height: 20),

            // ── Stats Row ───────────────────────────────────────────────
            Row(
              children: [
                Expanded(child: _buildStatCard(
                  title: "Streak",
                  metric: widget.entryCount > 0 ? "${widget.entryCount}" : "0",
                  unit: "days",
                  icon: CupertinoIcons.flame_fill,
                  color: amberAccent,
                )),
                const SizedBox(width: 14),
                Expanded(child: _buildStatCard(
                  title: "Entries",
                  metric: "${widget.entryCount}",
                  unit: "total",
                  icon: CupertinoIcons.book_fill,
                  color: accent,
                )),
              ],
            ),

            const SizedBox(height: 40),

            // ── Security ────────────────────────────────────────────────
            _sectionLabel("Security"),
            const SizedBox(height: 16),
            _buildSettingsGroup([
              _buildToggleTile(
                icon: CupertinoIcons.lock_shield_fill,
                label: "Require Passcode",
                subtitle: "Lock journal on exit",
                color: accent,
                value: securityState.isPasswordEnabled,
                onChanged: (val) {
                  if (val) _setupPasscodeDialog(context);
                  else ref.read(securityProvider.notifier).disablePassword();
                },
              ),
              if (securityState.isPasswordEnabled) ...[
                _divider(),
                _buildToggleTile(
                  icon: CupertinoIcons.device_phone_portrait,
                  label: "Fingerprint Unlock",
                  color: accent,
                  value: securityState.isFingerprintEnabled,
                  onChanged: (val) => ref.read(securityProvider.notifier).setFingerprintEnabled(val),
                ),
                _divider(),
                _buildToggleTile(
                  icon: CupertinoIcons.viewfinder,
                  label: "Face ID Unlock",
                  color: accent,
                  value: securityState.isFaceEnabled,
                  onChanged: (val) => ref.read(securityProvider.notifier).setFaceEnabled(val),
                ),
              ],
            ]),

            const SizedBox(height: 36),

            // ── Preferences ─────────────────────────────────────────────
            _sectionLabel("Preferences"),
            const SizedBox(height: 16),
            _buildSettingsGroup([
              _buildToggleTile(
                icon: widget.isDark ? CupertinoIcons.sun_max_fill : CupertinoIcons.moon_fill,
                label: "Dark Mode",
                color: accent,
                value: widget.isDark,
                onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
              ),
              _divider(),
              _buildInfoTile(
                icon: CupertinoIcons.info_circle,
                label: "Version",
                trailing: "1.0.0 · Ad-Free",
              ),
              _divider(),
              _buildActionTile(
                icon: CupertinoIcons.square_arrow_right,
                label: "Log Out",
                color: const Color(0xFFE05C5C),
                onTap: () async => await ref.read(authProvider.notifier).logout(),
              ),
            ]),

            const SizedBox(height: 36),

            // ── Contact ──────────────────────────────────────────────────
            _sectionLabel("Find me here"),
            const SizedBox(height: 16),
            _buildLinkButton(
              icon: CupertinoIcons.paperplane_fill,
              label: "Telegram",
              sublabel: "@Th3_honoured1",
              color: const Color(0xFF4BAEE8),
              onTap: () => _launchUrl("https://t.me/Th3_honoured1"),
            ),
            const SizedBox(height: 12),
            _buildLinkButton(
              icon: CupertinoIcons.mail_solid,
              label: "Email",
              sublabel: "christian4onos@gmail.com",
              color: const Color(0xFFE05C5C),
              onTap: () => _launchUrl("mailto:christian4onos@gmail.com"),
            ),
            const SizedBox(height: 12),
            _buildLinkButton(
              icon: CupertinoIcons.arrow_up_right_square_fill,
              label: "GitHub",
              sublabel: "The-honoured1",
              color: accent,
              onTap: () => _launchUrl("https://github.com/The-honoured1"),
            ),

            const SizedBox(height: 56),
          ],
        ),
      ),
    );
  }

  // ── Profile Hero ──────────────────────────────────────────────────────────
  Widget _buildProfileHero(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.isDark
              ? [const Color(0xFF211C3E), const Color(0xFF1A1630)]
              : [const Color(0xFFEDE8FF), const Color(0xFFF5F0E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: cardBorder),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showEditProfileDialog(context, user.name, user.profilePicUrl ?? ''),
            child: Stack(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: accent, width: 2.5),
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
                  bottom: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                    child: const Icon(CupertinoIcons.pencil, size: 11, color: Colors.white),
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
                  style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: widget.primaryText),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Reflecting daily",
                      style: GoogleFonts.outfit(fontSize: 13, color: widget.secondaryText),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Stat Card ─────────────────────────────────────────────────────────────
  Widget _buildStatCard({
    required String title,
    required String metric,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: widget.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                metric,
                style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w800, color: widget.primaryText),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: GoogleFonts.outfit(fontSize: 12, color: widget.secondaryText),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(title, style: GoogleFonts.outfit(fontSize: 13, color: widget.secondaryText)),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _sectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: widget.secondaryText,
        letterSpacing: 1.4,
      ),
    );
  }

  Widget _divider() => Divider(height: 1, thickness: 1, color: cardBorder, indent: 56, endIndent: 0);

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: widget.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cardBorder),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String label,
    String? subtitle,
    required Color color,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(label, style: GoogleFonts.outfit(color: widget.primaryText, fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: subtitle != null
          ? Text(subtitle, style: GoogleFonts.outfit(color: widget.secondaryText, fontSize: 12))
          : null,
      trailing: Switch(
        value: value,
        activeColor: color,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String trailing,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: widget.secondaryText.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: widget.secondaryText, size: 18),
      ),
      title: Text(label, style: GoogleFonts.outfit(color: widget.primaryText, fontWeight: FontWeight.w600, fontSize: 15)),
      trailing: Text(trailing, style: GoogleFonts.outfit(color: widget.secondaryText, fontSize: 13)),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(label, style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.w700, fontSize: 15)),
    );
  }

  // ── Link Button ───────────────────────────────────────────────────────────
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
        borderRadius: BorderRadius.circular(20),
        splashColor: color.withOpacity(0.1),
        highlightColor: color.withOpacity(0.06),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: widget.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.2), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: widget.primaryText)),
                    const SizedBox(height: 2),
                    Text(sublabel, style: GoogleFonts.outfit(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Icon(CupertinoIcons.chevron_right, color: color.withOpacity(0.5), size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
