import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'storage_provider.dart';

class ThemeNotifier extends StateNotifier<bool> {
  final Ref _ref;

  ThemeNotifier(this._ref) : super(false) {
    _init();
  }

  void _init() {
    state = _ref.read(storageServiceProvider).isDarkTheme();
  }

  Future<void> toggleTheme() async {
    state = !state;
    await _ref.read(storageServiceProvider).saveDarkTheme(state);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier(ref);
});
