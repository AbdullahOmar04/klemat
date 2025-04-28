import 'package:klemat/helper.dart';
import 'package:klemat/screens/3_letter_screen.dart';
import 'package:klemat/screens/4_letter_screen.dart';
import 'package:klemat/screens/5_letter_screen.dart';
import 'package:klemat/screens/daily_word.dart';
import 'package:klemat/themes/app_localization.dart';
import 'package:klemat/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> with RouteAware {
  bool isHardMode = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
    _loadDiamondCount();
  }

  @override
  void didPopNext() {
    _loadDiamondCount();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  Future<void> _loadDiamondCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      diamondAmount = prefs.getInt('diamondAmount') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              showStatsDialog(context);
            },
            icon: Icon(Icons.analytics),
          ),
          GestureDetector(
            child: coins(context, diamondAmount),
            onTap: () {
              openShop(context);
            },
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
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
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DailyMode()),
                );
              },
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
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FiveLetterScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  buildModeButton(
                    context,
                    AppLocalizations.of(context).translate('4_letter_mode'),
                    const Color.fromARGB(255, 255, 201, 120),
                    const Color.fromARGB(255, 255, 114, 20),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FourLetterScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  buildModeButton(
                    context,
                    AppLocalizations.of(context).translate('3_letter_mode'),
                    const Color.fromARGB(255, 219, 142, 255),
                    const Color.fromARGB(255, 104, 8, 148),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ThreeLetterScreen(),
                        ),
                      );
                    },
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
