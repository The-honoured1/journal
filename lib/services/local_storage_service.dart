import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/journal_entry.dart';
import '../core/constants.dart';

class LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  // Save journal entries
  Future<void> saveEntries(List<JournalEntry> entries) async {
    final list = entries.map((e) => e.toJson()).toList();
    await _prefs.setStringList(AppConstants.journalPrefsKey, list);
  }

  // Load journal entries
  List<JournalEntry> loadEntries() {
    final list = _prefs.getStringList(AppConstants.journalPrefsKey);
    if (list == null) {
      // Seed initial data so the user isn't greeted with a totally blank app
      final seedList = AppConstants.seedEntries.map((e) => JournalEntry.fromMap(e)).toList();
      saveEntries(seedList);
      return seedList;
    }
    return list.map((e) => JournalEntry.fromJson(e)).toList();
  }

  // Auth local cache
  Future<void> saveUserSession(String name, String email, bool isLoggedIn) async {
    await _prefs.setString(AppConstants.authNameKey, name);
    await _prefs.setString(AppConstants.authEmailKey, email);
    await _prefs.setBool(AppConstants.authLoggedInKey, isLoggedIn);
  }

  Map<String, dynamic> getUserSession() {
    return {
      'name': _prefs.getString(AppConstants.authNameKey) ?? 'Jose Maria',
      'email': _prefs.getString(AppConstants.authEmailKey) ?? 'jose.maria@solace.com',
      'isLoggedIn': _prefs.getBool(AppConstants.authLoggedInKey) ?? false,
    };
  }

  Future<void> clearUserSession() async {
    await _prefs.remove(AppConstants.authNameKey);
    await _prefs.remove(AppConstants.authEmailKey);
    await _prefs.setBool(AppConstants.authLoggedInKey, false);
  }

  // Theme settings
  Future<void> saveDarkTheme(bool isDark) async {
    await _prefs.setBool(AppConstants.themeModeKey, isDark);
  }

  bool isDarkTheme() {
    return _prefs.getBool(AppConstants.themeModeKey) ?? false;
  }
}
