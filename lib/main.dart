// Updated main.dart with Riverpod integration, Premium Spacious Layout, Security Lock, and no Emojis
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/storage_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/journal_provider.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/security_provider.dart';
import 'models/journal_entry.dart';
import 'screens/dashboard_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/reflection_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/lock_screen.dart';
import 'widgets/add_journal_bottom_sheet.dart';
import 'widgets/daily_checkin_modal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    final auth = ref.watch(authProvider);
    final securityState = ref.watch(securityProvider);

    return MaterialApp(
      title: 'Journal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getLightTheme(),
      darkTheme: AppTheme.getDarkTheme(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: auth.isLoggedIn
          ? (securityState.isLocked
              ? const LockScreen()
              : JournalAppHome(
                  isDarkTheme: isDark,
                  onToggleTheme: () => ref.read(themeProvider.notifier).toggleTheme(),
                ))
          : const WelcomeScreen(),
    );
  }
}

class JournalAppHome extends ConsumerStatefulWidget {
  final bool isDarkTheme;
  final VoidCallback onToggleTheme;

  const JournalAppHome({
    super.key,
    required this.isDarkTheme,
    required this.onToggleTheme,
  });

  @override
  ConsumerState<JournalAppHome> createState() => _JournalAppHomeState();
}

class _JournalAppHomeState extends ConsumerState<JournalAppHome> with WidgetsBindingObserver {
  int currentTabIndex = 0; // 0: Home, 1: Profile
  DateTime selectedDate = DateTime.now();
  bool isAudioPlaying = false;
  int audioCurrentSeconds = 0;
  double audioPlaybackProgress = 0.0;
  Timer? audioTimer;

  Set<String> selectedCategories = {"Personal", "Calm", "Motivation"};
  JournalEntry? activeReflectionDetail;
  String? todayMood;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDailyCheckin();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    audioTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Lock the app when paused/sent to background
    if (state == AppLifecycleState.paused) {
      ref.read(securityProvider.notifier).lock();
    }
  }

  void _checkDailyCheckin() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr = "${today.year}-${today.month}-${today.day}";
    if (prefs.getString('last_checkin_date') == todayStr) {
      final happy = prefs.getDouble('today_happy') ?? 0.5;
      final sad = prefs.getDouble('today_sad') ?? 0.1;
      final calm = prefs.getDouble('today_calm') ?? 0.5;
      final anxious = prefs.getDouble('today_anxious') ?? 0.1;
      
      String mood = "Calm";
      double maxVal = calm;
      if (happy > maxVal) { mood = "Happy"; maxVal = happy; }
      if (sad > maxVal) { mood = "Sad"; maxVal = sad; }
      if (anxious > maxVal) { mood = "Anxious"; }

      setState(() {
        todayMood = mood;
      });
    } else {
      if (mounted) {
        _showDailyCheckinModal();
      }
    }
  }

  void _showDailyCheckinModal() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Daily Check-in",
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return DailyCheckinModal(
          isDark: widget.isDarkTheme,
          onComplete: (happy, sad, calm, anxious, feelingsText) {
            _saveDailyCheckin(happy, sad, calm, anxious);

            String mood = "Calm";
            double maxVal = calm;
            if (happy > maxVal) { mood = "Happy"; maxVal = happy; }
            if (sad > maxVal) { mood = "Sad"; maxVal = sad; }
            if (anxious > maxVal) { mood = "Anxious"; }

            setState(() {
              todayMood = mood;
            });

            if (feelingsText.trim().isNotEmpty) {
              createNewJournalEntry(
                "Daily Check-in",
                feelingsText.trim(),
                "Personal",
                happy,
                sad,
                calm,
                anxious,
                [],
                [],
                null,
                0,
              );
            }
          },
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: anim1,
            child: child,
          ),
        );
      },
    );
  }

  void _saveDailyCheckin(double happy, double sad, double calm, double anxious) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr = "${today.year}-${today.month}-${today.day}";
    await prefs.setString('last_checkin_date', todayStr);
    await prefs.setDouble('today_happy', happy);
    await prefs.setDouble('today_sad', sad);
    await prefs.setDouble('today_calm', calm);
    await prefs.setDouble('today_anxious', anxious);
  }

  void toggleAudioPlayback() {
    setState(() {
      isAudioPlaying = !isAudioPlaying;
      if (isAudioPlaying) {
        audioTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            audioCurrentSeconds++;
            audioPlaybackProgress = (audioCurrentSeconds % 60) / 60.0;
          });
        });
      } else {
        audioTimer?.cancel();
      }
    });
  }

  void openReflection(JournalEntry entry) {
    setState(() {
      activeReflectionDetail = entry;
      isAudioPlaying = false;
      audioCurrentSeconds = 0;
      audioPlaybackProgress = 0.0;
      audioTimer?.cancel();
    });
  }

  void closeReflection() {
    setState(() {
      activeReflectionDetail = null;
      isAudioPlaying = false;
      audioCurrentSeconds = 0;
      audioPlaybackProgress = 0.0;
      audioTimer?.cancel();
    });
  }

  void deleteReflection(JournalEntry entry) {
    ref.read(journalProvider.notifier).deleteEntry(entry.id);
    closeReflection();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Journal entry deleted"),
        backgroundColor: Color(0xFF1E1A35),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatDateString(DateTime dt) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return "${months[dt.month - 1]} ${dt.day}, ${dt.year}";
  }

  void createNewJournalEntry(
    String title,
    String content,
    String primaryCategory,
    double happy,
    double sad,
    double calm,
    double anxious,
    List<String> imageUrls,
    List<String> fileNames,
    String? voiceNotePath,
    int voiceDurationSec,
  ) {
    String mood = "Calm";
    double maxVal = calm;
    if (happy > maxVal) { mood = "Happy"; maxVal = happy; }
    if (sad > maxVal) { mood = "Sad"; maxVal = sad; }
    if (anxious > maxVal) { mood = "Anxious"; }

    final newEntry = JournalEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      date: _formatDateString(selectedDate),
      text: content,
      mood: mood,
      categories: [primaryCategory],
      imageUrls: imageUrls,
      fileNames: fileNames,
      voiceNotePath: voiceNotePath,
      voiceDurationSec: voiceDurationSec,
      happyVal: happy,
      sadVal: sad,
      calmVal: calm,
      anxiousVal: anxious,
    );

    ref.read(journalProvider.notifier).addEntry(newEntry);

    setState(() {
      currentTabIndex = 0;
      activeReflectionDetail = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final journalEntries = ref.watch(journalProvider);
    final user = ref.watch(authProvider);
    
    final isDark = widget.isDarkTheme;
    final scaffoldBg = isDark ? const Color(0xFF0E0C1A) : const Color(0xFFF5F0E8);
    final cardBg = isDark ? const Color(0xFF1E1A35) : const Color(0xFFFFFDF8);
    final primaryText = isDark ? const Color(0xFFEDE8FF) : const Color(0xFF1A1628);
    final secondaryText = isDark ? const Color(0xFF8880A8) : const Color(0xFF6B6282);

    if (activeReflectionDetail != null) {
      return Scaffold(
        backgroundColor: scaffoldBg,
        body: SafeArea(
          bottom: false,
          child: ReflectionScreen(
            entry: activeReflectionDetail!,
            isDark: isDark,
            primaryText: primaryText,
            secondaryText: secondaryText,
            cardBg: cardBg,
            isPlaying: isAudioPlaying,
            playbackSeconds: audioCurrentSeconds,
            playbackProgress: audioPlaybackProgress,
            onPlayToggle: toggleAudioPlayback,
            onBack: closeReflection,
            onDelete: () => deleteReflection(activeReflectionDetail!),
            selectedCategories: selectedCategories,
            onCategoryToggle: (category) {
              setState(() {
                if (selectedCategories.contains(category)) {
                  if (selectedCategories.length > 1) {
                    selectedCategories.remove(category);
                  }
                } else {
                  selectedCategories.add(category);
                }
              });
            },
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentTabIndex == 0
                            ? "Hi, ${user.name}"
                            : "My Profile",
                        style: TextStyle(
                          fontSize: 26,
                          fontFamily: 'serif',
                          fontWeight: FontWeight.w900,
                          color: primaryText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (currentTabIndex == 0)
                        Text(
                          todayMood != null
                              ? "Today you are feeling $todayMood."
                              : "Ready for a peaceful day?",
                          style: TextStyle(fontSize: 14, color: secondaryText, fontWeight: FontWeight.w500),
                        ),
                      if (currentTabIndex == 1)
                        Text(
                          "Adjust your personal settings.",
                          style: TextStyle(fontSize: 14, color: secondaryText, fontWeight: FontWeight.w500),
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: widget.onToggleTheme,
                        icon: Icon(
                          isDark
                              ? CupertinoIcons.sun_max_fill
                              : CupertinoIcons.moon_fill,
                          color: isDark ? const Color(0xFF9B7FE8) : const Color(0xFF3D2B8E),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? const Color(0xFF9B7FE8) : const Color(0xFF3D2B8E),
                            width: 2,
                          ),
                          image: DecorationImage(
                            image: NetworkImage(
                              user.profilePicUrl ?? "https://images.unsplash.com/photo-1513836279014-a89f7a76ae86?w=150&auto=format&fit=crop&q=80",
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: IndexedStack(
                index: currentTabIndex,
                children: [
                  DashboardScreen(
                    isDark: isDark,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                    cardBg: cardBg,
                    selectedDate: selectedDate,
                    onDateSelect: (date) {
                      setState(() {
                        selectedDate = date;
                      });
                    },
                    onOpenJournal: openReflection,
                    journalEntries: journalEntries,
                  ),
                  ProfileScreen(
                    isDark: isDark,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                    cardBg: cardBg,
                    entryCount: journalEntries.length,
                  ),
                ],
              ),
            ),
            _buildBottomNavBar(isDark, cardBg),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(bool isDark, Color cardBg) {
    final activeColor = isDark ? const Color(0xFF9B7FE8) : const Color(0xFF3D2B8E);
    final inactiveColor = isDark ? const Color(0xFF6860A0) : const Color(0xFF9E98B5);

    return Container(
      padding: const EdgeInsets.only(bottom: 28, top: 16, left: 24, right: 24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x1F000000) : const Color(0x0F000000),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            0,
            currentTabIndex == 0 ? CupertinoIcons.house_fill : CupertinoIcons.house,
            "Home",
            activeColor,
            inactiveColor,
          ),
          
          GestureDetector(
            onTap: () => _showAddJournalModal(context),
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF9B7FE8), const Color(0xFF6D4FC2)]
                      : [const Color(0xFF5A3FBF), const Color(0xFF3D2B8E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? const Color(0xFF9B7FE8).withOpacity(0.35)
                        : const Color(0xFF3D2B8E).withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                CupertinoIcons.add,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          
          _buildNavItem(
            1,
            currentTabIndex == 1 ? CupertinoIcons.person_fill : CupertinoIcons.person,
            "Profile",
            activeColor,
            inactiveColor,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    Color activeColor,
    Color inactiveColor,
  ) {
    final isSelected = currentTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          currentTabIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 65,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddJournalModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AddJournalBottomSheet(
          isDark: widget.isDarkTheme,
          onSave: createNewJournalEntry,
        );
      },
    );
  }
}
