import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/security_provider.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen>
    with SingleTickerProviderStateMixin {
  final List<String> _enteredPin = [];
  bool _isBiometricScanning = false;
  bool _isSuccess = false;
  bool _hasError  = false;
  String _biometricType = '';
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = ref.read(securityProvider);
      if (s.isFingerprintEnabled) {
        setState(() => _biometricType = 'fingerprint');
        _triggerBiometricScan();
      } else if (s.isFaceEnabled) {
        setState(() => _biometricType = 'face');
        _triggerBiometricScan();
      }
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _triggerBiometricScan() {
    if (_isSuccess || _isBiometricScanning) return;
    setState(() { _isBiometricScanning = true; _hasError = false; });

    Timer(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      setState(() { _isBiometricScanning = false; _isSuccess = true; });
      HapticFeedback.mediumImpact();
      Timer(const Duration(milliseconds: 400), () {
        if (mounted) ref.read(securityProvider.notifier).unlock();
      });
    });
  }

  void _onKeyPress(String key) {
    if (_isSuccess || _hasError) return;
    HapticFeedback.lightImpact();

    setState(() {
      if (key == 'back') {
        if (_enteredPin.isNotEmpty) _enteredPin.removeLast();
      } else {
        if (_enteredPin.length < 4) {
          _enteredPin.add(key);
          if (_enteredPin.length == 4) _verifyPin();
        }
      }
    });
  }

  void _verifyPin() {
    final s       = ref.read(securityProvider);
    final entered = _enteredPin.join();

    if (entered == s.password) {
      setState(() => _isSuccess = true);
      HapticFeedback.heavyImpact();
      Timer(const Duration(milliseconds: 400), () {
        if (mounted) ref.read(securityProvider.notifier).unlock();
      });
    } else {
      setState(() => _hasError = true);
      HapticFeedback.vibrate();
      _shakeController.forward(from: 0.0);
      Timer(const Duration(milliseconds: 800), () {
        if (mounted) setState(() { _enteredPin.clear(); _hasError = false; });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Midnight Ink palette
    final bg      = isDark ? const Color(0xFF0E0C1A) : const Color(0xFFF5F0E8);
    final accent  = isDark ? const Color(0xFF9B7FE8) : const Color(0xFF3D2B8E);
    final priText = isDark ? const Color(0xFFEDE8FF) : const Color(0xFF1A1628);
    final secText = isDark ? const Color(0xFF8880A8) : const Color(0xFF6B6282);
    final keyBg   = isDark ? const Color(0xFF1E1A35) : const Color(0xFFFFFDF8);
    final keyBorder = isDark ? const Color(0xFF2E2A4A) : const Color(0xFFE8DFD0);
    final dotActive   = isDark ? const Color(0xFF9B7FE8) : const Color(0xFF3D2B8E);
    final dotInactive = isDark ? const Color(0xFF2E2A4A) : const Color(0xFFE8DFD0);

    final successColor  = const Color(0xFF5CB88A);
    final errorColor    = const Color(0xFFE05C5C);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),

            // ── Lock icon ──────────────────────────────────────────────
            AnimatedBuilder(
              animation: _shakeController,
              builder: (_, child) {
                final offset = math.sin(_shakeController.value * math.pi * 5) * 10;
                return Transform.translate(
                  offset: Offset(_hasError ? offset : 0, 0),
                  child: child,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: _isSuccess
                      ? successColor.withOpacity(0.12)
                      : (_hasError ? errorColor.withOpacity(0.12) : accent.withOpacity(0.10)),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _isSuccess
                        ? successColor.withOpacity(0.3)
                        : (_hasError ? errorColor.withOpacity(0.3) : accent.withOpacity(0.25)),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  _isSuccess
                      ? CupertinoIcons.lock_open_fill
                      : (_hasError ? CupertinoIcons.xmark_circle_fill : CupertinoIcons.lock_fill),
                  size: 36,
                  color: _isSuccess ? successColor : (_hasError ? errorColor : accent),
                ),
              ),
            ),

            const SizedBox(height: 28),

            Text(
              _isSuccess ? "Welcome Back" : (_hasError ? "Incorrect Passcode" : "Secure Journal"),
              style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700, color: priText),
            ),
            const SizedBox(height: 8),
            Text(
              _isSuccess
                  ? "Your sanctuary is unlocked."
                  : (_hasError ? "Please try again." : "Enter your passcode to continue"),
              style: GoogleFonts.outfit(fontSize: 14, color: secText),
            ),

            const SizedBox(height: 52),

            // ── PIN dots ───────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final isActive = i < _enteredPin.length;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 14, height: 14,
                  decoration: BoxDecoration(
                    color: isActive ? dotActive : dotInactive,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),

            const Spacer(flex: 2),

            // ── Biometric button ───────────────────────────────────────
            if (_biometricType.isNotEmpty && !_isSuccess) ...[
              GestureDetector(
                onTap: _triggerBiometricScan,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: keyBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: accent.withOpacity(0.25), width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _isBiometricScanning
                          ? SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: accent),
                            )
                          : Icon(
                              _biometricType == 'fingerprint'
                                  ? CupertinoIcons.device_phone_portrait
                                  : CupertinoIcons.viewfinder,
                              size: 18, color: accent,
                            ),
                      const SizedBox(width: 10),
                      Text(
                        _isBiometricScanning
                            ? "Verifying..."
                            : (_biometricType == 'fingerprint' ? "Fingerprint Unlock" : "Face ID Unlock"),
                        style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: accent),
                      ),
                    ],
                  ),
                ),
              ).animate(target: _isBiometricScanning ? 1.0 : 0.0)
                .shimmer(duration: 1200.ms, color: Colors.white24),
              const SizedBox(height: 36),
            ],

            // ── Keypad ─────────────────────────────────────────────────
            Container(
              constraints: const BoxConstraints(maxWidth: 300),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  _keyRow(['1','2','3'], keyBg, keyBorder, priText),
                  const SizedBox(height: 14),
                  _keyRow(['4','5','6'], keyBg, keyBorder, priText),
                  const SizedBox(height: 14),
                  _keyRow(['7','8','9'], keyBg, keyBorder, priText),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _biometricType.isNotEmpty
                          ? _buildBioKey(keyBg, keyBorder, accent)
                          : const SizedBox(width: 72, height: 72),
                      _buildKey('0', keyBg, keyBorder, priText),
                      _buildKey('back', keyBg, keyBorder, priText),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }

  Row _keyRow(List<String> keys, Color bg, Color border, Color text) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: keys.map((k) => _buildKey(k, bg, border, text)).toList(),
      );

  Widget _buildKey(String key, Color bg, Color border, Color text) {
    final isBack = key == 'back';
    return Container(
      width: 72, height: 72,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: border, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onKeyPress(key),
          customBorder: const CircleBorder(),
          child: Center(
            child: isBack
                ? Icon(CupertinoIcons.delete_left, color: text, size: 22)
                : Text(key, style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w500, color: text)),
          ),
        ),
      ),
    );
  }

  Widget _buildBioKey(Color bg, Color border, Color accent) {
    return Container(
      width: 72, height: 72,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: border, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _triggerBiometricScan,
          customBorder: const CircleBorder(),
          child: Center(
            child: Icon(
              _biometricType == 'fingerprint'
                  ? CupertinoIcons.device_phone_portrait
                  : CupertinoIcons.viewfinder,
              color: accent, size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
