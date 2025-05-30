import 'package:firebase_auth/firebase_auth.dart';
import 'package:klemat/helper.dart';
import 'package:klemat/screens/daily_word.dart';
import 'package:klemat/screens/leaderboard.dart';
import 'package:klemat/screens/level_map.dart';
import 'package:klemat/screens/library.dart';
import 'package:klemat/screens/login.dart';
import 'package:klemat/themes/app_localization.dart';
import 'package:klemat/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainMenu extends StatefulWidget {
  final String username;

  const MainMenu({super.key, required this.username});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> with RouteAware {
  bool isHardMode = false;
  late int diamonds = 0;
  final userData = UserDataService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    _loadUserData();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final amount = await userData.loadDiamonds();
    final streaks = await userData.loadStreaks();
    final stats = await userData.loadStats();
    final levels = await userData.loadCurrentLevels();

    setState(() {
      diamonds = amount;
      winStreak = streaks['winStreak'] ?? 0;
      dailyWinStreak = streaks['dailyWinStreak'] ?? 0;
      timeWinStreak = streaks['timeWinStreak'] ?? 0;
      currentFiveModeLevel = levels['five']!;
      currentFourModeLevel = levels['four']!;
      currentThreeModeLevel = levels['three']!;

      GameStatsSnapshot.played = stats['played'] ?? 0;
      GameStatsSnapshot.wins = stats['wins'] ?? 0;
      GameStatsSnapshot.currentStreak = stats['currentStreak'] ?? 0;
      GameStatsSnapshot.maxStreak = stats['maxStreak'] ?? 0;
      GameStatsSnapshot.distribution = Map<int, int>.from(
        stats['distribution'] ?? {},
      );
    });
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LeaderboardPage(),
                  ),
                );
              },
              icon: const Icon(Icons.leaderboard, color: Colors.white),
              label: Text(
                AppLocalizations.of(context).translate("leaderboard"),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 7,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                elevation: 5,
              ),
            ),
          ],
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          GestureDetector(
            onTap: () => openShop(context),
            child: coins(context, diamonds),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.username,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.bar_chart),
              title: Text(AppLocalizations.of(context).translate('stats')),
              onTap: () => showStatsDialog(context),
            ),
            ListTile(
              leading: Icon(Icons.book),
              title: Text(AppLocalizations.of(context).translate('library')),
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Library()),
                  ),
            ),
            ListTile(
              leading: Icon(Icons.question_mark),
              title: Text(
                AppLocalizations.of(context).translate('how_to_play'),
              ),
              onTap: () => showHowToPlayDialog(context),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text(AppLocalizations.of(context).translate('log_out')),
              onTap: () async => await _logout(context),
            ),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              Theme.of(context).brightness == Brightness.dark
                  ? 'assets/images/dark_background.png'
                  : 'assets/images/white_background.png',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset('assets/images/Mountains.png', height: 200),
            ),
            longBuildModeButton(
              context,
              AppLocalizations.of(context).translate('daily_mode'),
              Colors.green.shade300,
              Colors.teal.shade300,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DailyMode()),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  buildModeButton(
                    context,
                    AppLocalizations.of(context).translate('5_letter_mode'),
                    const Color.fromARGB(255, 142, 212, 241),
                    const Color.fromARGB(255, 0, 125, 179),
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => LevelMapPage(
                              "Mode 5",
                              currentLevel: currentFiveModeLevel,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  buildModeButton(
                    context,
                    AppLocalizations.of(context).translate('4_letter_mode'),
                    const Color.fromARGB(255, 255, 201, 120),
                    const Color.fromARGB(255, 255, 114, 20),
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => LevelMapPage(
                              "Mode 4",
                              currentLevel: currentFourModeLevel,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  buildModeButton(
                    context,
                    AppLocalizations.of(context).translate('3_letter_mode'),
                    const Color.fromARGB(255, 219, 142, 255),
                    const Color.fromARGB(255, 104, 8, 148),
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => LevelMapPage(
                              "Mode 3",
                              currentLevel: currentThreeModeLevel,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                smallButton(
                  context,
                  const Icon(Icons.settings, color: Colors.white),
                  const Color.fromARGB(255, 206, 206, 206),
                  Colors.grey.shade700,
                  () => showSettingsDialog(context, themeNotifier),
                ),
                const SizedBox(width: 10),
                smallButton(
                  context,
                  const Icon(Icons.emoji_events, color: Colors.white, size: 35),
                  const Color.fromARGB(255, 189, 255, 250),
                  const Color.fromARGB(255, 0, 185, 185),
                  () => challenges(context),
                ),
                const SizedBox(width: 10),
                smallButton(
                  context,
                  const Icon(Icons.storefront_outlined, color: Colors.white),
                  const Color.fromARGB(255, 255, 169, 163),
                  const Color.fromARGB(255, 255, 47, 32),
                  () => openShop(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
