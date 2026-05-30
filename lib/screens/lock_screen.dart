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

class _LockScreenState extends ConsumerState<LockScreen> with SingleTickerProviderStateMixin {
  final List<String> _enteredPin = [];
  bool _isBiometricScanning = false;
  bool _isSuccess = false;
  bool _hasError = false;
  String _biometricType = ''; // 'fingerprint', 'face', or ''
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Auto-trigger biometric scan if enabled
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final securityState = ref.read(securityProvider);
      if (securityState.isFingerprintEnabled) {
        setState(() {
          _biometricType = 'fingerprint';
        });
        _triggerBiometricScan();
      } else if (securityState.isFaceEnabled) {
        setState(() {
          _biometricType = 'face';
        });
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

    setState(() {
      _isBiometricScanning = true;
      _hasError = false;
    });

    // Simulate standard authentic biometric scanning
    Timer(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      
      setState(() {
        _isBiometricScanning = false;
        _isSuccess = true;
      });

      // Vibrate on success
      HapticFeedback.mediumImpact();

      Timer(const Duration(milliseconds: 400), () {
        if (mounted) {
          ref.read(securityProvider.notifier).unlock();
        }
      });
    });
  }

  void _onKeyPress(String key) {
    if (_isSuccess || _hasError) return;

    HapticFeedback.lightImpact();

    setState(() {
      if (key == 'back') {
        if (_enteredPin.isNotEmpty) {
          _enteredPin.removeLast();
        }
      } else {
        if (_enteredPin.length < 4) {
          _enteredPin.add(key);
        }

        // Verify when 4 digits are completed
        if (_enteredPin.length == 4) {
          _verifyPin();
        }
      }
    });
  }

  void _verifyPin() {
    final securityState = ref.read(securityProvider);
    final entered = _enteredPin.join();

    if (entered == securityState.password) {
      setState(() {
        _isSuccess = true;
      });
      HapticFeedback.heavyImpact();
      Timer(const Duration(milliseconds: 400), () {
        if (mounted) {
          ref.read(securityProvider.notifier).unlock();
        }
      });
    } else {
      setState(() {
        _hasError = true;
      });
      HapticFeedback.vibrate();
      _shakeController.forward(from: 0.0);
      
      Timer(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _enteredPin.clear();
            _hasError = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final securityState = ref.watch(securityProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Sleek cinematic warm dark/sage tones
    final bgGradient = isDark
        ? const RadialGradient(
            center: Alignment(0, -0.3),
            radius: 1.3,
            colors: [
              Color(0xFF151C18), // Deep Forest Obsidian
              Color(0xFF0C0E0D), // Pure Black Obsidian
            ],
          )
        : const RadialGradient(
            center: Alignment(0, -0.3),
            radius: 1.3,
            colors: [
              Color(0xFFF6F8F5), // Light warm sage tint
              Color(0xFFEEF1EC), // Clean soft linen
            ],
          );

    final primaryText = isDark ? const Color(0xFFECEFEA) : const Color(0xFF1E2421);
    final secondaryText = isDark ? const Color(0xFF8FA397) : const Color(0xFF5B6E62);
    final keyColor = isDark ? const Color(0xFF1E2621) : const Color(0xFFE2E9E3);
    final dotColorActive = isDark ? const Color(0xFF63A375) : const Color(0xFF347A4B);
    final dotColorInactive = isDark ? const Color(0xFF2E3B33) : const Color(0xFFCAD4CC);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Locked Icon & Title
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _isSuccess
                      ? (isDark ? const Color(0x2263A375) : const Color(0x22347A4B))
                      : (_hasError ? const Color(0x22EF5350) : Colors.transparent),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isSuccess
                      ? CupertinoIcons.lock_open_fill
                      : (_hasError ? CupertinoIcons.xmark_circle_fill : CupertinoIcons.lock_fill),
                  size: 42,
                  color: _isSuccess
                      ? (isDark ? const Color(0xFF86DCA0) : const Color(0xFF2E7D46))
                      : (_hasError ? Colors.redAccent : primaryText),
                ),
              ).animate(target: _hasError ? 1.0 : 0.0)
                .shake(hz: 8, curve: Curves.easeInOut),

              const SizedBox(height: 24),

              Text(
                _isSuccess
                    ? "Welcome Back"
                    : (_hasError ? "Incorrect Passcode" : "Secure Journal"),
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: primaryText,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _isSuccess
                    ? "Sanctuary unlocked."
                    : (_hasError ? "Please try again." : "Enter your passcode to unlock your journal"),
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: secondaryText,
                ),
              ),

              const SizedBox(height: 48),

              // PIN Indicator dots
              AnimatedBuilder(
                animation: _shakeController,
                builder: (context, child) {
                  final offset = math.sin(_shakeController.value * math.pi * 4) * 8;
                  return Transform.translate(
                    offset: Offset(_hasError ? offset : 0, 0),
                    child: child,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final isActive = index < _enteredPin.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: isActive ? dotColorActive : dotColorInactive,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isActive ? Colors.transparent : secondaryText.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const Spacer(flex: 2),

              // Biometric option if enabled
              if (_biometricType.isNotEmpty && !_isSuccess) ...[
                GestureDetector(
                  onTap: _triggerBiometricScan,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161E1A) : const Color(0xFFE2E9E3),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark ? const Color(0x3363A375) : const Color(0x33347A4B),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _isBiometricScanning
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF63A375)),
                                ),
                              )
                            : Icon(
                                _biometricType == 'fingerprint'
                                    ? CupertinoIcons.device_phone_portrait
                                    : CupertinoIcons.viewfinder,
                                size: 20,
                                color: isDark ? const Color(0xFF86DCA0) : const Color(0xFF2E7D46),
                              ),
                        const SizedBox(width: 12),
                        Text(
                          _isBiometricScanning
                              ? "Verifying Identity..."
                              : (_biometricType == 'fingerprint'
                                  ? "Unlock with Fingerprint"
                                  : "Unlock with Face ID"),
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF86DCA0) : const Color(0xFF2E7D46),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate(target: _isBiometricScanning ? 1.0 : 0.0)
                  .shimmer(duration: 1200.ms, color: Colors.white24),
                const SizedBox(height: 36),
              ],

              // Keypad (spacious and beautifully round)
              Container(
                constraints: const BoxConstraints(maxWidth: 320),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: ['1', '2', '3'].map((k) => _buildKey(k, keyColor, primaryText)).toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: ['4', '5', '6'].map((k) => _buildKey(k, keyColor, primaryText)).toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: ['7', '8', '9'].map((k) => _buildKey(k, keyColor, primaryText)).toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Left extra placeholder / biometric icon trigger
                        _biometricType.isNotEmpty
                            ? _buildBiometricTriggerButton(keyColor, isDark)
                            : const SizedBox(width: 70, height: 70),
                        _buildKey('0', keyColor, primaryText),
                        _buildKey('back', keyColor, primaryText),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKey(String key, Color keyColor, Color textColor) {
    final isBack = key == 'back';
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: keyColor,
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onKeyPress(key),
          customBorder: const CircleBorder(),
          child: Center(
            child: isBack
                ? Icon(CupertinoIcons.delete_left, color: textColor, size: 22)
                : Text(
                    key,
                    style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricTriggerButton(Color keyColor, bool isDark) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: keyColor.withOpacity(0.4),
        shape: BoxShape.circle,
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
              color: isDark ? const Color(0xFF86DCA0) : const Color(0xFF2E7D46),
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
