// Updated main.dart with Riverpod integration
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/storage_provider.dart';
import 'providers/auth_provider.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/reflection_screen.dart';
import 'screens/welcome_screen.dart';
import 'widgets/add_journal_bottom_sheet.dart';

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

    return MaterialApp(
      title: 'Journal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getLightTheme(),
      darkTheme: AppTheme.getDarkTheme(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: auth.isLoggedIn
          ? JournalAppHome(
              isDarkTheme: isDark,
              onToggleTheme: () => ref.read(themeProvider.notifier).toggleTheme(),
            )
          : const WelcomeScreen(),
    );
  }
}

class JournalAppHome extends StatefulWidget {
  final bool isDarkTheme;
  final VoidCallback onToggleTheme;

  const JournalAppHome({
    super.key,
    required this.isDarkTheme,
    required this.onToggleTheme,
  });

  @override
  State<JournalAppHome> createState() => _JournalAppHomeState();
}

class _JournalAppHomeState extends State<JournalAppHome> {
  int currentTabIndex =
      0; // 0: Home, 1: Explore, 2: Journey (Analytics), 3: Profile
  int selectedDayIndex = 3; // Thursday (10)
  int activeScore = 420;
  bool isAudioPlaying = false;
  int audioCurrentSeconds = 32;
  double audioPlaybackProgress = 0.45;
  Timer? audioTimer;

  Set<String> selectedCategories = {"Personal", "Calm", "Motivation"};

  List<Map<String, dynamic>> journalEntries = [
    {
      "title": "Morning Reflection",
      "date": "March 22, 2025",
      "text":
          "I woke up to the soft light filtering through my window, and for the first time in a while, I didn’t rush to check my phone. Instead, I took a deep breath and stretched, feeling my body wake up slowly. The morning routine felt deliberate and peaceful.",
      "bullets": [
        "The warmth of my morning tea",
        "A quiet moment to myself before the day starts",
        "The kindness of a stranger who held the door open for me yesterday",
      ],
      "categories": ["Personal", "Calm", "Motivation"],
    },
  ];

  double happyPercent = 0.48;
  double sadPercent = 0.33;
  double calmPercent = 0.27;
  double anxiousPercent = 0.40;

  Map<String, dynamic>? activeReflectionDetail;

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

  void selectDay(int index) {
    setState(() {
      selectedDayIndex = index;
    });
  }

  void openReflection(Map<String, dynamic> entry) {
    setState(() {
      activeReflectionDetail = entry;
    });
  }

  void closeReflection() {
    setState(() {
      activeReflectionDetail = null;
    });
  }

  void deleteReflection(Map<String, dynamic> entry) {
    setState(() {
      journalEntries.remove(entry);
      activeReflectionDetail = null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Journal entry deleted"),
          backgroundColor: Color(0xFF78473B),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  void createNewJournalEntry(
    String title,
    String content,
    String primaryCategory,
    double happy,
    double sad,
    double calm,
    double anxious,
  ) {
    setState(() {
      final newEntry = {
        "title": title,
        "date": "May 29, 2026",
        "text": content,
        "bullets": [
          "Took a moment to log my state",
          "Explored my emotional space today",
          "Committed to mindfulness",
        ],
        "categories": [primaryCategory, "Calm"],
      };
      journalEntries.insert(0, newEntry);

      activeScore += 15;
      happyPercent = (happyPercent + happy) / 2;
      sadPercent = (sadPercent + sad) / 2;
      calmPercent = (calmPercent + calm) / 2;
      anxiousPercent = (anxiousPercent + anxious) / 2;

      currentTabIndex = 0;
      activeReflectionDetail = null;
    });
  }

  @override
  void dispose() {
    audioTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkTheme;
    final scaffoldBg = isDark
        ? const Color(0xFF1C1A18)
        : const Color(0xFFF5F2EB);
    final cardBg = isDark ? const Color(0xFF282522) : Colors.white;
    final primaryText = isDark
        ? const Color(0xFFECE7E2)
        : const Color(0xFF2C2A29);
    final secondaryText = isDark
        ? const Color(0xFF9E9992)
        : const Color(0xFF7C7975);

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
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentTabIndex == 0
                            ? "Hi, Jose Maria"
                            : currentTabIndex == 2
                            ? "My Journal"
                            : currentTabIndex == 1
                            ? "Explore Solace"
                            : "My Journey",
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: 'serif',
                          fontWeight: FontWeight.w900,
                          color: primaryText,
                        ),
                      ),
                      if (currentTabIndex == 0)
                        Text(
                          "Ready for a peaceful day?",
                          style: TextStyle(fontSize: 14, color: secondaryText),
                        ),
                      if (currentTabIndex == 2)
                        Text(
                          "Celebrate what made you smile.",
                          style: TextStyle(fontSize: 14, color: secondaryText),
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
                          color: const Color(0xFFFFB534),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFFB534),
                            width: 1.5,
                          ),
                          image: const DecorationImage(
                            image: NetworkImage(
                              "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&auto=format&fit=crop&q=80",
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
            Expanded(
              child: IndexedStack(
                index: currentTabIndex,
                children: [
                  DashboardScreen(
                    isDark: isDark,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                    cardBg: cardBg,
                    selectedDayIndex: selectedDayIndex,
                    onDaySelect: selectDay,
                    onOpenJournal: () {
                      if (journalEntries.isNotEmpty) {
                        openReflection(journalEntries.first);
                      }
                    },
                    journalEntries: journalEntries,
                  ),
                  ExploreScreen(
                    isDark: isDark,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                    cardBg: cardBg,
                  ),
                  AnalyticsScreen(
                    isDark: isDark,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                    cardBg: cardBg,
                    activeScore: activeScore,
                    happy: happyPercent,
                    sad: sadPercent,
                    calm: calmPercent,
                    anxious: anxiousPercent,
                    onCreateNew: () => _showAddJournalModal(context),
                  ),
                  ProfileScreen(
                    isDark: isDark,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                    cardBg: cardBg,
                    entryCount: journalEntries.length,
                    activeScore: activeScore,
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
    final activeColor = isDark ? Colors.white : const Color(0xFF2C2A29);
    final inactiveColor = isDark
        ? const Color(0xFF6C6864)
        : const Color(0xFFB0AAA4);

    return Container(
      padding: const EdgeInsets.only(bottom: 24, top: 12, left: 16, right: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(
            0,
            currentTabIndex == 0
                ? CupertinoIcons.house_fill
                : CupertinoIcons.house,
            "Home",
            activeColor,
            inactiveColor,
          ),
          _buildNavItem(
            1,
            currentTabIndex == 1
                ? CupertinoIcons.compass_fill
                : CupertinoIcons.compass,
            "Explore",
            activeColor,
            inactiveColor,
          ),
          // Center Floating + Button
          GestureDetector(
            onTap: () => _showAddJournalModal(context),
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Color(
                  0xFFFBB540,
                ), // Bright yellow-orange matching reference
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x33FBB540),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                CupertinoIcons.add,
                color: Color(0xFF2C2A29),
                size: 28,
              ),
            ),
          ),
          _buildNavItem(
            2,
            currentTabIndex == 2
                ? CupertinoIcons.doc_text_fill
                : CupertinoIcons.doc_text,
            "Journey",
            activeColor,
            inactiveColor,
          ),
          _buildNavItem(
            3,
            currentTabIndex == 3
                ? CupertinoIcons.person_fill
                : CupertinoIcons.person,
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
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
