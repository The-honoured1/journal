import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'storage_provider.dart';

class SecurityState {
  final bool isLocked;
  final bool isPasswordEnabled;
  final String password;
  final bool isFingerprintEnabled;
  final bool isFaceEnabled;

  SecurityState({
    required this.isLocked,
    required this.isPasswordEnabled,
    required this.password,
    required this.isFingerprintEnabled,
    required this.isFaceEnabled,
  });

  SecurityState copyWith({
    bool? isLocked,
    bool? isPasswordEnabled,
    String? password,
    bool? isFingerprintEnabled,
    bool? isFaceEnabled,
  }) {
    return SecurityState(
      isLocked: isLocked ?? this.isLocked,
      isPasswordEnabled: isPasswordEnabled ?? this.isPasswordEnabled,
      password: password ?? this.password,
      isFingerprintEnabled: isFingerprintEnabled ?? this.isFingerprintEnabled,
      isFaceEnabled: isFaceEnabled ?? this.isFaceEnabled,
    );
  }
}

class SecurityNotifier extends StateNotifier<SecurityState> {
  final SharedPreferences _prefs;

  SecurityNotifier(this._prefs)
      : super(SecurityState(
          isLocked: _prefs.getBool('security_enabled') ?? false,
          isPasswordEnabled: _prefs.getBool('security_enabled') ?? false,
          password: _prefs.getString('security_password') ?? '',
          isFingerprintEnabled: _prefs.getBool('security_fingerprint') ?? false,
          isFaceEnabled: _prefs.getBool('security_face') ?? false,
        ));

  Future<void> enablePassword(String newPassword) async {
    await _prefs.setBool('security_enabled', true);
    await _prefs.setString('security_password', newPassword);
    state = state.copyWith(
      isPasswordEnabled: true,
      password: newPassword,
      isLocked: true,
    );
  }

  Future<void> disablePassword() async {
    await _prefs.setBool('security_enabled', false);
    await _prefs.setString('security_password', '');
    await _prefs.setBool('security_fingerprint', false);
    await _prefs.setBool('security_face', false);
    state = state.copyWith(
      isPasswordEnabled: false,
      password: '',
      isFingerprintEnabled: false,
      isFaceEnabled: false,
      isLocked: false,
    );
  }

  Future<void> setFingerprintEnabled(bool enabled) async {
    await _prefs.setBool('security_fingerprint', enabled);
    state = state.copyWith(isFingerprintEnabled: enabled);
  }

  Future<void> setFaceEnabled(bool enabled) async {
    await _prefs.setBool('security_face', enabled);
    state = state.copyWith(isFaceEnabled: enabled);
  }

  void lock() {
    if (state.isPasswordEnabled) {
      state = state.copyWith(isLocked: true);
    }
  }

  void unlock() {
    state = state.copyWith(isLocked: false);
  }
}

final securityProvider = StateNotifierProvider<SecurityNotifier, SecurityState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SecurityNotifier(prefs);
});
