import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
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

class GameStatsSnapshot {
  static int played = 0;
  static int wins = 0;
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
    builder: (context) {
      return AlertDialog(
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
                                backgroundColor: Colors.grey[300],
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
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).translate('close')),
          ),
        ],
      );
    },
  );
}

Widget coins(BuildContext context, int amount) {
  return Container(
    margin: const EdgeInsets.only(right: 12),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        const Icon(Icons.diamond, size: 20, color: Colors.cyanAccent),
        const SizedBox(width: 4),
        Text('$amount', style: const TextStyle(color: Colors.white70)),
      ],
    ),
  );
}

void openShop(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(AppLocalizations.of(context).translate('shop')),
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
  }) async {
    if (uid == null) return;
    await _userRef.doc(uid).set({
      'winStreak': winStreak,
      'dailyWinStreak': dailyWinStreak,
      'timeWinStreak': timeWinStreak,
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
  Future<void> recordGame({required bool won, required int guesses}) async {
    if (uid == null) return;
    final ref = _userRef.doc(uid);
    final snap = await ref.get();
    final data = snap.data() as Map<String, dynamic>? ?? {};

    int played = (data['stats_played'] ?? 0) + 1;
    int wins = data['stats_wins'] ?? 0;
    int currentStreak = data['stats_currentStreak'] ?? 0;
    int maxStreak = data['stats_maxStreak'] ?? 0;

    if (won) {
      wins++;
      currentStreak++;
      if (currentStreak > maxStreak) maxStreak = currentStreak;
    } else {
      currentStreak = 0;
    }

    int dist = (data['stats_dist_$guesses'] ?? 0) + 1;

    await ref.set({
      'stats_played': played,
      'stats_wins': wins,
      'stats_currentStreak': currentStreak,
      'stats_maxStreak': maxStreak,
      'stats_dist_$guesses': dist,
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>> loadStats() async {
    if (uid == null) return {};
    final snap = await _userRef.doc(uid).get();
    final data = snap.data() as Map<String, dynamic>? ?? {};

    final dist = <int, int>{};
    for (int i = 1; i <= 6; i++) {
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

  /// Initialize user data on sign up
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
  showDialog(
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
                    _statTile('${GameStatsSnapshot.played}', 'Games\nPlayed'),
                    _statTile(
                      '${GameStatsSnapshot.wins.toStringAsFixed(0)}%',
                      'Win\n  %',
                    ),
                    _statTile(
                      '${GameStatsSnapshot.currentStreak}',
                      'Current\n Streak',
                    ),
                    _statTile(
                      '${GameStatsSnapshot.maxStreak}',
                      '  Max\nStreak',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Guess Distribution',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                const SizedBox(height: 8),
                for (int i = 1; i <= 6; i++)
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
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context).translate('close')),
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
  // Set the default language index: 0 for English, 1 for Arabic.
  int selectedLangIndex =
      Localizations.localeOf(context).languageCode == 'ar' ? 1 : 0;
  // Get the current theme mode.
  ThemeMode currentTheme = themeNotifier.themeMode;

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    AppLocalizations.of(context).translate('settings'),
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 20),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(
                              context,
                            ).translate('choose_lang'),
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          DropdownButton<int>(
                            value: selectedLangIndex,
                            items: const [
                              DropdownMenuItem(
                                value: 0,
                                child: Text('English'),
                              ),
                              DropdownMenuItem(
                                value: 1,
                                child: Text('العربية'),
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
                        ],
                      ),
                    ),
                  ),

                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: SwitchListTile(
                      title: Text(
                        AppLocalizations.of(
                          context,
                        ).translate('enable_vibration'),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      value: isHapticEnabled,
                      onChanged: (bool value) async {
                        setState(() {
                          isHapticEnabled = value;
                        });
                        await prefs.setBool('isHapticEnabled', isHapticEnabled);
                      },
                    ),
                  ),

                  // Theme Section
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            AppLocalizations.of(
                              context,
                            ).translate('choose_theme'),
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          RadioListTile<ThemeMode>(
                            title: Text(
                              AppLocalizations.of(
                                context,
                              ).translate('light_mode'),
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
                          RadioListTile<ThemeMode>(
                            title: Text(
                              AppLocalizations.of(
                                context,
                              ).translate('dark_mode'),
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
                          RadioListTile<ThemeMode>(
                            title: Text(
                              AppLocalizations.of(
                                context,
                              ).translate('system_mode'),
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
                  ),

                  // Close Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      AppLocalizations.of(context).translate('close'),
                    ),
                  ),
                ],
              ),
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
            // Restore scale and execute action after animation
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
  VoidCallback? onTick;

  GameTimer({this.onTick});

  void start() {
    _timer?.cancel();
    elapsedSeconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      elapsedSeconds++;
      if (onTick != null) {
        onTick!();
      }
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
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      AppLocalizations.of(context).translate('close'),
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
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(AppLocalizations.of(context).translate('close')),
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
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(AppLocalizations.of(context).translate('goal_desc')),
              const SizedBox(height: 15),
              Text(
                AppLocalizations.of(context).translate('letter_colors'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _colorHintRow(
                Colors.green,
                AppLocalizations.of(context).translate('correct_letter_position'),
              ),
              _colorHintRow(
                Colors.orange,
                AppLocalizations.of(context).translate('correct_letter_wrong_spot'),
              ),
              _colorHintRow(
                Colors.grey,
                AppLocalizations.of(context).translate('letter_not_in_word'),
              ),
              const SizedBox(height: 15),
              Text(
                AppLocalizations.of(context).translate('bonus'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(AppLocalizations.of(context).translate('bonus_desc')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppLocalizations.of(context).translate('got_it')),
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
