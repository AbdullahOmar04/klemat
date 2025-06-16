import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:klemat/main.dart';
import 'package:klemat/themes/app_localization.dart';
import 'package:klemat/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

List gottenWords = [];

int currentFiveModeLevel = 1;
int currentFourModeLevel = 1;
int currentThreeModeLevel = 1;

int winStreak = 0;
int dailyWinStreak = 0;
int timeWinStreak = 0;
int points = 0;

class GameStatsSnapshot {
  static int played = 0;
  static double wins = 0.0;
  static int currentStreak = 0;
  static int maxStreak = 0;
  static Map<int, int> distribution = {};
}

class Challenge {
  final String title;
  final int currentVal;
  final int goal;
  final int reward;

  Challenge({
    required this.title,
    required this.goal,
    required this.currentVal,
    required this.reward,
  });

  double get progress => currentVal / goal;
}

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

void challenges(BuildContext context) {
  final List<Challenge> challenges = [
    Challenge(
      title: AppLocalizations.of(context).translate('win_3_in_a_row'),
      currentVal: winStreak,
      goal: 3,
      reward: 50,
    ),
    Challenge(
      title: AppLocalizations.of(context).translate('solve_under_2'),
      currentVal: timeWinStreak,
      goal: 1,
      reward: 30,
    ),
    Challenge(
      title: AppLocalizations.of(context).translate('daily_challenge'),
      currentVal: dailyWinStreak,
      goal: 7,
      reward: 150,
    ),
  ];

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppLocalizations.of(context).translate('challenges'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 30,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                challenges.map((challenge) {
                  return ListTile(
                    leading: Icon(Icons.military_tech_rounded),
                    title: Text(challenge.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${AppLocalizations.of(context).translate("progress")}: ${challenge.currentVal}/${challenge.goal}",
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: challenge.progress.clamp(0.0, 1.0),
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  141,
                                  141,
                                  141,
                                ),
                                color: Colors.blue,
                              ),
                            ),
                            SizedBox(width: 5),
                            Text("${challenge.reward}"),
                            Icon(Icons.diamond, color: Colors.blue),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Theme.of(context).colorScheme.onError,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context).translate('close'),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge!.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

Widget coins(BuildContext context, int amount) {
  return ElevatedButton.icon(
    onPressed: () => openShop(context),
    icon: Icon(Icons.diamond_rounded, color: Colors.cyan, size: 20),
    label: Text('$amount', style: TextStyle(color: Colors.white)),
    style: ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).colorScheme.primary,
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      elevation: 5,
    ),
  );
}

void openShop(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(AppLocalizations.of(context).translate('shop')),
        actions: [Text('Coming Soon!')],
      );
    },
  );
}

class UserDataService {
  final String? uid = FirebaseAuth.instance.currentUser?.uid;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _userRef =>
      FirebaseFirestore.instance.collection('users');

  /// Load diamond amount
  Future<int> loadDiamonds() async {
    if (uid == null) return 0;
    final doc = await _userRef.doc(uid).get();
    final data = doc.data() as Map<String, dynamic>?;
    return data?['diamonds'] ?? 0;
  }

  /// Award diamonds
  Future<void> awardDiamonds(int amount) async {
    if (uid == null) return;
    final doc = await _userRef.doc(uid).get();
    final data = doc.data() as Map<String, dynamic>?;
    int current = data?['diamonds'] ?? 0;
    await _userRef.doc(uid).set({
      'diamonds': current + amount,
    }, SetOptions(merge: true));
  }

  /// Load win/daily/time streaks
  Future<Map<String, int>> loadStreaks() async {
    if (uid == null) return {};
    final doc = await _userRef.doc(uid).get();
    final data = doc.data() as Map<String, dynamic>?;
    return {
      'winStreak': data?['winStreak'] ?? 0,
      'dailyWinStreak': data?['dailyWinStreak'] ?? 0,
      'timeWinStreak': data?['timeWinStreak'] ?? 0,
    };
  }

  /// Save streaks
  Future<void> saveStreaks({
    required int winStreak,
    required int dailyWinStreak,
    required int timeWinStreak,
    required int points,
  }) async {
    if (uid == null) return;
    await _userRef.doc(uid).set({
      'winStreak': winStreak,
      'dailyWinStreak': dailyWinStreak,
      'timeWinStreak': timeWinStreak,
      'points': points,
    }, SetOptions(merge: true));
  }

  Future<int> getCurrentLevel(String mode) async {
    final doc = await _db.collection('users').doc(uid).get();
    final data = doc.data() ?? {};
    return data['currentLevel$mode'] ?? 1;
  }

  Future<void> setCurrentLevel(String mode, int level) async {
    await _db.collection('users').doc(uid).set({
      'currentLevel$mode': level,
    }, SetOptions(merge: true));
  }

  /// Record game stats
  Future<void> recordGame({
    required bool won,
    int? guesses, // make guesses optional
  }) async {
    if (uid == null) return;
    final ref = _userRef.doc(uid);

    // 1) Read existing stats
    final snap = await ref.get();
    final data = snap.data() as Map<String, dynamic>? ?? {};

    int played = (data['stats_played'] ?? 0) + 1;
    int winsCount = data['stats_wins'] ?? 0;
    int currentStreak = data['stats_currentStreak'] ?? 0;
    int maxStreak = data['stats_maxStreak'] ?? 0;

    if (won) {
      winsCount++;
      currentStreak++;
      if (currentStreak > maxStreak) {
        maxStreak = currentStreak;
      }
    } else {
      currentStreak = 0;
    }

    // 2) Build the Firestore payload
    final Map<String, Object> updates = {
      'stats_played': played,
      'stats_wins': winsCount,
      'stats_currentStreak': currentStreak,
      'stats_maxStreak': maxStreak,
    };

    // Only increment distribution if user actually won and provided a valid 'guesses'
    if (won && guesses != null && guesses >= 1 && guesses <= 7) {
      final int distCount = (data['stats_dist_$guesses'] ?? 0) + 1;
      updates['stats_dist_$guesses'] = distCount;
    }

    // 3) Send merged update to Firestore
    await ref.set(updates, SetOptions(merge: true));

    // 4) Update in‐memory snapshot
    GameStatsSnapshot.played = played;
    GameStatsSnapshot.wins = (played > 0) ? (winsCount * 100.0 / played) : 0.0;
    GameStatsSnapshot.currentStreak = currentStreak;
    GameStatsSnapshot.maxStreak = maxStreak;

    // Rebuild distribution map from Firestore data (only keys 1..7)
    final Map<int, int> newDist = {};
    for (int i = 1; i <= 7; i++) {
      // If won and i == guesses, use distCount; otherwise use Firestore’s value (or 0).
      if (won && guesses == i) {
        newDist[i] = (data['stats_dist_$i'] ?? 0) + 1;
      } else {
        newDist[i] = data['stats_dist_$i'] ?? 0;
      }
    }
    GameStatsSnapshot.distribution = newDist;
  }

  Future<Map<String, dynamic>> loadStats() async {
    if (uid == null) return {};

    final snap = await _userRef.doc(uid).get();
    final data = snap.data() as Map<String, dynamic>? ?? {};

    final dist = <int, int>{};
    for (int i = 1; i <= 7; i++) {
      // ▶ changed upper bound to 7
      dist[i] = data['stats_dist_$i'] ?? 0;
    }

    return {
      'played': data['stats_played'] ?? 0,
      'wins': data['stats_wins'] ?? 0,
      'currentStreak': data['stats_currentStreak'] ?? 0,
      'maxStreak': data['stats_maxStreak'] ?? 0,
      'distribution': dist,
    };
  }

  Future<void> spendDiamonds(int amount) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'diamonds': FieldValue.increment(-amount),
      });
    }
  }

  Future<Map<String, int>> loadCurrentLevels() async {
    final user = FirebaseAuth.instance.currentUser;
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .get();
    final data = doc.data() ?? {};

    return {
      'five': data['currentLevel5'],
      'four': data['currentLevel4'],
      'three': data['currentLevel3'],
    };
  }

  Future<void> initializeUser({required String username}) async {
    if (uid == null) return;
    final doc = await _userRef.doc(uid).get();
    if (!doc.exists) {
      await _userRef.doc(uid).set({
        'diamonds': 0,
        'winStreak': 0,
        'dailyWinStreak': 0,
        'timeWinStreak': 0,
        'currentLevel3': 1,
        'currentLevel4': 1,
        'currentLevel5': 1,
        'stats_played': 0,
        'stats_wins': 0,
        'stats_currentStreak': 0,
        'stats_maxStreak': 0,
        'stats_dist_1': 0,
        'stats_dist_2': 0,
        'stats_dist_3': 0,
        'stats_dist_4': 0,
        'stats_dist_5': 0,
        'stats_dist_6': 0,
        'stats_dist_7': 0,
        'username': username,
        'score': 0,
      });
    }
  }

  Future<List<String>> loadGottenWords() async {
    if (uid == null) return [];
    final doc = await _userRef.doc(uid).get();
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final List<dynamic> words = data['gottenWords'] ?? [];
    return List<String>.from(words);
  }

  Future<void> addGottenWord(String word) async {
    if (uid == null) return;
    final ref = _userRef.doc(uid);
    await ref.set({
      'gottenWords': FieldValue.arrayUnion([word]),
    }, SetOptions(merge: true));
  }

  Future<void> updateLeaderboard({
    required String username,
    required int score,
  }) async {
    if (uid == null) return;

    await FirebaseFirestore.instance.collection('leaderboard').doc(uid).set({
      'username': username,
      'score': score,
      'wins': FieldValue.increment(1),
      'gamesPlayed': FieldValue.increment(1),
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

Future<void> showStatsDialog(BuildContext context) async {
  // 1) Load fresh stats from Firestore
  final stats = await UserDataService().loadStats();
  final int playedCount = stats['played'] as int? ?? 0;
  final int rawWinsCount = stats['wins'] as int? ?? 0;
  final int currentStreakFromFS = stats['currentStreak'] as int? ?? 0;
  final int maxStreakFromFS = stats['maxStreak'] as int? ?? 0;
  final Map<int, int> distMap = Map<int, int>.from(
    stats['distribution'] as Map<int, dynamic>,
  );

  // 2) Overwrite in‐memory snapshot
  GameStatsSnapshot.played = playedCount;
  GameStatsSnapshot.wins =
      (playedCount > 0) ? (rawWinsCount * 100.0 / playedCount) : 0.0;
  GameStatsSnapshot.currentStreak = currentStreakFromFS;
  GameStatsSnapshot.maxStreak = maxStreakFromFS;
  GameStatsSnapshot.distribution = distMap;

  // 3) Show the AlertDialog
  showDialog(
    barrierDismissible: false,
    context: context,
    builder:
        (_) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            AppLocalizations.of(context).translate('stats'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _statTile(
                      '${GameStatsSnapshot.played}',
                      AppLocalizations.of(context).translate('games_played'),
                    ),
                    _statTile(
                      '${GameStatsSnapshot.wins.toStringAsFixed(0)}%',
                      AppLocalizations.of(context).translate('win_percent'),
                    ),
                    _statTile(
                      '${GameStatsSnapshot.currentStreak}',
                      AppLocalizations.of(context).translate('current_streak'),
                    ),
                    _statTile(
                      '${GameStatsSnapshot.maxStreak}',
                      AppLocalizations.of(context).translate('max_streak'),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    AppLocalizations.of(
                      context,
                    ).translate('guess_distribution'),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                const SizedBox(height: 8),
                // ▶ Change 6 → 7 so that we render seven bars
                for (int i = 1; i <= 7; i++)
                  _buildBarRow(
                    context,
                    i,
                    GameStatsSnapshot.distribution[i]!,
                    GameStatsSnapshot.played,
                  ),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.onError,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context).translate('close'),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge!.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
  );
}

Widget _statTile(String value, String label) {
  return Column(
    children: [
      Text(
        value,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      Text(label, style: const TextStyle(fontSize: 12)),
    ],
  );
}

Widget _buildBarRow(
  BuildContext context,
  int guessCount,
  int count,
  int played,
) {
  final fraction = played > 0 ? count / played : 0.0;
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        SizedBox(
          width: 20,
          child: Text('$guessCount', textAlign: TextAlign.right),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: fraction,
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text('$count'),
      ],
    ),
  );
}

void showSettingsDialog(
  BuildContext context,
  ThemeNotifier themeNotifier,
) async {
  final prefs = await SharedPreferences.getInstance();
  bool isHapticEnabled = prefs.getBool('isHapticEnabled') ?? true;
  int selectedLangIndex =
      Localizations.localeOf(context).languageCode == 'ar' ? 1 : 0;
  ThemeMode currentTheme = themeNotifier.themeMode;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context).translate('settings'),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // ─── CONTENT ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // — Language Selection —
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 4),
                        child: Text(
                          AppLocalizations.of(context).translate('choose_lang'),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            value: selectedLangIndex,
                            items: [
                              DropdownMenuItem(
                                value: 0,
                                child: Text(
                                  'English',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                              DropdownMenuItem(
                                value: 1,
                                child: Text(
                                  'العربية',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedLangIndex = value!;
                                if (selectedLangIndex == 0) {
                                  MyApp.setLocale(
                                    context,
                                    const Locale('en', 'US'),
                                  );
                                } else {
                                  MyApp.setLocale(
                                    context,
                                    const Locale('ar', 'SA'),
                                  );
                                }
                              });
                            },
                          ),
                        ),
                      ),

                      // — Haptic (Vibration) Toggle —
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const SizedBox.shrink(),
                        subtitle: Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            AppLocalizations.of(
                              context,
                            ).translate('enable_vibration'),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        value: isHapticEnabled,
                        onChanged: (bool value) async {
                          setState(() {
                            isHapticEnabled = value;
                          });
                          await prefs.setBool(
                            'isHapticEnabled',
                            isHapticEnabled,
                          );
                        },
                        activeColor: Theme.of(context).colorScheme.onPrimary,
                      ),

                      // — Theme Selection —
                      Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 4),
                        child: Text(
                          AppLocalizations.of(
                            context,
                          ).translate('choose_theme'),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          children: [
                            RadioListTile<ThemeMode>(
                              visualDensity: VisualDensity.compact,
                              title: Text(
                                AppLocalizations.of(
                                  context,
                                ).translate('light_mode'),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              value: ThemeMode.light,
                              groupValue: currentTheme,
                              onChanged: (ThemeMode? value) {
                                setState(() {
                                  currentTheme = value!;
                                  themeNotifier.setTheme(currentTheme);
                                });
                              },
                            ),
                            const Divider(height: 1),
                            RadioListTile<ThemeMode>(
                              visualDensity: VisualDensity.compact,
                              title: Text(
                                AppLocalizations.of(
                                  context,
                                ).translate('dark_mode'),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              value: ThemeMode.dark,
                              groupValue: currentTheme,
                              onChanged: (ThemeMode? value) {
                                setState(() {
                                  currentTheme = value!;
                                  themeNotifier.setTheme(currentTheme);
                                });
                              },
                            ),
                            const Divider(height: 1),
                            RadioListTile<ThemeMode>(
                              visualDensity: VisualDensity.compact,
                              title: Text(
                                AppLocalizations.of(
                                  context,
                                ).translate('system_mode'),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              value: ThemeMode.system,
                              groupValue: currentTheme,
                              onChanged: (ThemeMode? value) {
                                setState(() {
                                  currentTheme = value!;
                                  themeNotifier.setTheme(currentTheme);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ─── ACTIONS ──────────────────────────────────────────────
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.onError,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context).translate('close'),
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge!.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}

Widget longBuildModeButton(
  BuildContext context,
  String text,
  Color gradStart,
  Color gradEnd,
  VoidCallback onPressed,
) {
  double scale = 1.0;

  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: InkWell(
          onTap: () async {
            setState(() => scale = 1.0);
            await Future.delayed(const Duration(milliseconds: 100));
            onPressed();
          },
          onTapDown: (_) {
            setState(() => scale = 0.95);
          },
          onTapCancel: () {
            setState(() => scale = 1.0);
          },
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          child: AnimatedScale(
            scale: scale,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [gradStart, gradEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  minimumSize: const Size.fromHeight(120),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: ListTile(
                  leading: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 56,
                        color: Colors.white,
                      ),
                      Positioned(
                        top: 18,
                        child: Text(
                          '${DateTime.now().day}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  title: Center(
                    child: Text(
                      text,
                      style: const TextStyle(fontSize: 34, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget buildModeButton(
  BuildContext context,
  String text,
  Color gradStart,
  Color gradEnd,
  VoidCallback onPressed,
) {
  double scale = 1.0;

  return StatefulBuilder(
    builder:
        (context, setState) => Expanded(
          child: InkWell(
            onTap: () async {
              // Restore scale and execute action after animation
              setState(() => scale = 1.0);
              onPressed();
            },
            onTapDown: (_) {
              // Shrink the button immediately on tap
              setState(() => scale = 0.95);
            },
            onTapCancel: () {
              // Restore scale if the tap is canceled
              setState(() => scale = 1.0);
            },
            overlayColor: const WidgetStatePropertyAll(Colors.transparent),
            child: AnimatedScale(
              scale: scale,
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeInOut,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [gradStart, gradEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize:
                          Localizations.localeOf(context).languageCode == 'ar'
                              ? 19
                              : 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
  );
}

Widget smallButton(
  BuildContext context,
  Icon icon,
  Color gradStart,
  Color gradEnd,
  VoidCallback onPressed,
) {
  double scale = 1.0;

  return StatefulBuilder(
    builder:
        (context, setState) => InkWell(
          onTap: () async {
            setState(() => scale = 1.0);
            await Future.delayed(const Duration(milliseconds: 100));
            onPressed();
          },
          onTapDown: (_) {
            setState(() => scale = 0.90);
          },
          onTapCancel: () {
            setState(() => scale = 1.0);
          },
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          child: AnimatedScale(
            scale: scale,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [gradStart, gradEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: icon,
              ),
            ),
          ),
        ),
  );
}

class GameTimer {
  Timer? _timer;
  int elapsedSeconds = 0;
  final VoidCallback? onTick;

  GameTimer({this.onTick});

  void start({bool reset = true}) {
    _timer?.cancel();
    if (reset) elapsedSeconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsedSeconds++;
      onTick?.call();
    });
  }

  void stop() {
    _timer?.cancel();
  }

  void reset() {
    stop();
    elapsedSeconds = 0;
  }

  String get formattedTime {
    final minutes = elapsedSeconds ~/ 60;
    final seconds = elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

Future<List<String>> parseWords(String jsonString, String key) async {
  return compute(_parseWords, {"jsonString": jsonString, "key": key});
}

List<String> _parseWords(Map<String, dynamic> args) {
  String jsonString = args["jsonString"];
  String key = args["key"];
  final data = json.decode(jsonString);
  return List<String>.from(data[key]);
}

class HintedTextField extends StatefulWidget {
  final String hint;

  final TextEditingController controller;

  final TextStyle? textStyle;

  const HintedTextField({
    super.key,
    required this.hint,
    required this.controller,
    this.textStyle,
  });

  @override
  State<HintedTextField> createState() => _HintedTextFieldState();
}

class _HintedTextFieldState extends State<HintedTextField> {
  @override
  void initState() {
    super.initState();
    // Listen to changes so we can update the UI.
    widget.controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    widget.controller.removeListener(() => setState(() {}));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (widget.controller.text.isEmpty)
          Text(
            widget.hint,
            style:
                widget.textStyle ??
                TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 24),
          ),
        TextField(
          controller: widget.controller,
          style:
              widget.textStyle ??
              const TextStyle(color: Colors.black, fontSize: 24),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: '',
            contentPadding: EdgeInsets.all(8),
          ),
        ),
      ],
    );
  }
}

Future<List<String>> fetchAlmaanyDefinitions(
  BuildContext context,
  String word,
) async {
  final uri = Uri.parse('https://www.almaany.com/ar/dict/ar-ar/$word/?');
  final res = await http.get(uri);
  if (res.statusCode != 200) {
    throw Exception('Failed to load definitions (HTTP ${res.statusCode})');
  }

  final document = parse(res.body);

  // grab either <li class="more">…</li> OR <div class="shortcontent">…</div>
  final nodes = document.querySelectorAll(
    'ol.meaning-results li ul li.more, ol.meaning-results li div.shortcontent',
  );

  if (nodes.isEmpty) {
    return [AppLocalizations.of(context).translate('def_not_found')];
  }

  return nodes
      .map((n) => n.text.trim().replaceAll(RegExp(r'\s+'), ' '))
      .where((t) => t.isNotEmpty)
      .toList();
}

void showDefinitionDialog(BuildContext context, String word) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder:
        (ctx) => FutureBuilder<List<String>>(
          future: fetchAlmaanyDefinitions(context, word),
          builder: (ctx, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return AlertDialog(
                title: Text('Error'),
                content: Text(snap.error.toString()),
                actions: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.onError,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context).translate('close'),
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge!.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            final defs = snap.data!;
            return AlertDialog(
              title: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: AppLocalizations.of(
                        context,
                      ).translate('learn_word'),
                      style:
                          Localizations.localeOf(context).languageCode == 'ar'
                              ? TextStyle(
                                fontSize: 23,
                                color: Theme.of(context).colorScheme.onSurface,
                              )
                              : TextStyle(
                                fontSize: 20,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                    ),
                    TextSpan(
                      text: "$word\n",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue.shade300,
                      ),
                      recognizer:
                          TapGestureRecognizer()
                            ..onTap = () {
                              launchUrl(
                                Uri.parse(
                                  'https://www.almaany.com/ar/dict/ar-ar/$word/?',
                                ),
                              );
                            },
                    ),

                    TextSpan(
                      text: AppLocalizations.of(context).translate('pronounce'),
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.blue.shade300,
                      ),
                      recognizer:
                          TapGestureRecognizer()
                            ..onTap = () {
                              launchUrl(
                                Uri.parse('https://forvo.com/word/$word'),
                              );
                            },
                    ),
                  ],
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: defs.take(5).map((d) => Text('• $d')).toList(),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.onError,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context).translate('close'),
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge!.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
  );
}

void incorrectWordDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder:
        (context) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            AppLocalizations.of(context).translate('incorrect'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          content: Text(
            AppLocalizations.of(context).translate('try_again'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.onError,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context).translate('close'),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge!.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
  );
}

void showIncorrectDailyDialog(BuildContext context, String word) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder:
        (context) => FutureBuilder<List<String>>(
          future: fetchAlmaanyDefinitions(context, word),
          builder: (ctx, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return AlertDialog(
                backgroundColor: Theme.of(context).colorScheme.surface,
                content: SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            if (snap.hasError) {
              return AlertDialog(
                backgroundColor: Theme.of(context).colorScheme.surface,
                title: Text('Error'),
                content: Text(snap.error.toString()),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(
                      AppLocalizations.of(context).translate('close'),
                    ),
                  ),
                ],
              );
            }

            final List<String> definitions = snap.data!;
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: Text(
                AppLocalizations.of(context).translate('incorrect'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text:
                                '${AppLocalizations.of(context).translate('correct_word')}: ',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 16,
                            ),
                          ),
                          TextSpan(
                            text: word,
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.blue.shade300,
                            ),
                            recognizer:
                                TapGestureRecognizer()
                                  ..onTap = () {
                                    launchUrl(
                                      Uri.parse(
                                        'https://www.almaany.com/ar/dict/ar-ar/$word/?',
                                      ),
                                    );
                                  },
                          ),
                          TextSpan(
                            text: AppLocalizations.of(
                              context,
                            ).translate('pronounce'),
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.blue.shade300,
                            ),
                            recognizer:
                                TapGestureRecognizer()
                                  ..onTap = () {
                                    launchUrl(
                                      Uri.parse('https://forvo.com/word/$word'),
                                    );
                                  },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          definitions
                              .take(5)
                              .map(
                                (def) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4.0,
                                  ),
                                  child: Text('• $def'),
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    AppLocalizations.of(context).translate('got_it'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
  );
}

void showHowToPlayDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return AlertDialog(
        title: Text(
          AppLocalizations.of(context).translate('how_to_play'),
          style: const TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).translate('goal'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(AppLocalizations.of(context).translate('goal_desc')),
              const SizedBox(height: 15),
              Text(
                AppLocalizations.of(context).translate('letter_colors'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _colorHintRow(
                Colors.green,
                AppLocalizations.of(
                  context,
                ).translate('correct_letter_position'),
              ),
              _colorHintRow(
                Colors.orange,
                AppLocalizations.of(
                  context,
                ).translate('correct_letter_wrong_spot'),
              ),
              _colorHintRow(
                Colors.grey,
                AppLocalizations.of(context).translate('letter_not_in_word'),
              ),
              const SizedBox(height: 15),
              Text(
                AppLocalizations.of(context).translate('bonus'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(AppLocalizations.of(context).translate('bonus_desc')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text(
              AppLocalizations.of(context).translate('got_it'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
}

Widget _colorHintRow(Color color, String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

int calculatePoints(String mode, int wonAtRow, int hintsUsed) {
  int earned = 0;

  if (mode == 'Daily') {
    switch (wonAtRow) {
      case 0:
        earned = 15;
        break;
      case 1:
        earned = 14;
        break;
      case 2:
        earned = 13;
        break;
      case 3:
        earned = 12;
        break;
      case 4:
        earned = 11;
        break;
      case 5:
        earned = 10;
        break;
      case 6:
        earned = 9;
        break;
      default:
        earned = 0;
    }
  }

  if (mode == 'Mode 5') {
    switch (wonAtRow) {
      case 0:
        earned = 10;
        break;
      case 1:
        earned = 9;
        break;
      case 2:
        earned = 8;
        break;
      case 3:
        earned = 7;
        break;
      case 4:
        earned = 6;
        break;
      case 5:
        earned = 5;
        break;
      case 6:
        earned = 4;
        break;
      default:
        earned = 0;
    }
  }

  if (mode == 'Mode 4') {
    switch (wonAtRow) {
      case 0:
        earned = 8;
        break;
      case 1:
        earned = 7;
        break;
      case 2:
        earned = 6;
        break;
      case 3:
        earned = 5;
        break;
      case 4:
        earned = 4;
        break;
      case 5:
        earned = 3;
        break;
      case 6:
        earned = 2;
        break;
      default:
        earned = 0;
    }
  }

  if (mode == 'Mode 3') {
    switch (wonAtRow) {
      case 0:
        earned = 6;
        break;
      case 1:
        earned = 5;
        break;
      case 2:
        earned = 4;
        break;
      case 3:
        earned = 3;
        break;
      case 4:
        earned = 2;
        break;
      case 5:
        earned = 1;
        break;
      case 6:
        earned = 1;
        break;
      default:
        earned = 0;
    }
  }

  earned = max(0, earned - hintsUsed);

  return earned;
}

Future<void> triggerHapticFeedback() async {
  final prefs = await SharedPreferences.getInstance();
  bool isHapticEnabled = prefs.getBool('isHapticEnabled') ?? true;
  if (isHapticEnabled) {
    HapticFeedback.lightImpact();
  }
}
