import 'dart:async';
import 'dart:convert';

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

int winStreak = 0;
int dailyWinStreak = 0;
int timeWinStreak = 0;
int diamondAmount = 0;
int currentFiveModeLevel = 1;

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
      title: 'Win 3 games in a row',
      currentVal: winStreak,
      goal: 3,
      reward: 50,
    ),
    Challenge(
      title: 'Solve a game in under 2 minutes',
      currentVal: timeWinStreak,
      goal: 1,
      reward: 30,
    ),
    Challenge(
      title: 'Daily Streak: Solve daily for 7 days',
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
          'Challenges',
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
                          'Progress: ${challenge.currentVal}/${challenge.goal}',
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
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}

Widget coins(BuildContext context, int amount) {
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: const Color.fromARGB(94, 131, 131, 131),
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      border: Border.all(
        width: 5,
        color: Theme.of(context).colorScheme.surface,
      ),
    ),
    child: Row(
      children: [
        const Icon(Icons.diamond, color: Colors.blue),
        const SizedBox(width: 10),
        Text('$amount', style: const TextStyle(fontSize: 15)),
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

Future<void> awardDiamonds(int amount) async {
  final prefs = await SharedPreferences.getInstance();
  // Read the current stored diamond amount
  int currentAmount = prefs.getInt('diamondAmount') ?? 0;
  currentAmount += amount;
  await prefs.setInt('diamondAmount', currentAmount);
}

class GameStats {
  static const _playedKey = 'stats_played';
  static const _winsKey = 'stats_wins';
  static const _currentKey = 'stats_currentStreak';
  static const _maxKey = 'stats_maxStreak';
  // one key per guess count:
  static String _distKey(int i) => 'stats_dist_$i';

  /// Call this once at the end of every round:
  static Future<void> recordGame({
    required bool won,
    required int guesses,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // overall games played
    int played = (prefs.getInt(_playedKey) ?? 0) + 1;
    await prefs.setInt(_playedKey, played);

    // wins
    int wins = prefs.getInt(_winsKey) ?? 0;
    if (won) {
      wins++;
      await prefs.setInt(_winsKey, wins);
      // update streak
      int current = (prefs.getInt(_currentKey) ?? 0) + 1;
      await prefs.setInt(_currentKey, current);
      int maxStreak = prefs.getInt(_maxKey) ?? 0;
      if (current > maxStreak) {
        await prefs.setInt(_maxKey, current);
      }
    } else {
      await prefs.setInt(_currentKey, 0);
    }

    int old = prefs.getInt(_distKey(guesses)) ?? 0;
    await prefs.setInt(_distKey(guesses), old + 1);
  }

  static Future<_StatsSnapshot> load() async {
    final p = await SharedPreferences.getInstance();
    final played = p.getInt(_playedKey) ?? 0;
    final wins = p.getInt(_winsKey) ?? 0;
    final current = p.getInt(_currentKey) ?? 0;
    final maxs = p.getInt(_maxKey) ?? 0;
    final dist = <int, int>{
      for (var i = 1; i <= 6; i++) i: p.getInt(_distKey(i)) ?? 0,
    };
    return _StatsSnapshot(
      played: played,
      wins: wins,
      currentStreak: current,
      maxStreak: maxs,
      distribution: dist,
    );
  }
}

class _StatsSnapshot {
  final int played, wins, currentStreak, maxStreak;
  final Map<int, int> distribution;
  _StatsSnapshot({
    required this.played,
    required this.wins,
    required this.currentStreak,
    required this.maxStreak,
    required this.distribution,
  });
  double get winPct => played > 0 ? wins / played * 100 : 0;
}

Future<void> showStatsDialog(BuildContext context) async {
  final snap = await GameStats.load();

  showDialog(
    context: context,
    builder:
        (_) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            'Statistics',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _statTile('${snap.played}', 'Games\nPlayed'),
                    _statTile('${snap.winPct.toStringAsFixed(0)}%', 'Win\n  %'),
                    _statTile('${snap.currentStreak}', 'Current\n Streak'),
                    _statTile('${snap.maxStreak}', '  Max\nStreak'),
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
                  _buildBarRow(context, i, snap.distribution[i]!, snap.played),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
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

                  // Language Selection Section
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
  double scale = 1.0; // Button's scale factor

  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: InkWell(
          onTap: () async {
            // Restore scale and execute action after animation
            setState(() => scale = 1.0);
            await Future.delayed(const Duration(milliseconds: 100));
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
                onPressed: null, // InkWell handles tap logic
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
                      style: const TextStyle(fontSize: 28, color: Colors.white),
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
  /// The hint (the letter to display as watermark).
  final String hint;

  /// The controller for the text field.
  final TextEditingController controller;

  /// Optional: additional styling for the text field.
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
                    child: Text('Close'),
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
                              ? TextStyle(fontSize: 25)
                              : TextStyle(fontSize: 20),
                    ),
                    TextSpan(
                      text: word,
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
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Close'),
                ),
              ],
            );
          },
        ),
  );
}

void levelsMap(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(child: Container(child: Image.network("https://as1.ftcdn.net/jpg/04/33/56/10/1000_F_433561046_ZukvohmWL49nY8fSDiG70zw3pNbMuRnK.jpg"),),),
      );
    },
  );
}
