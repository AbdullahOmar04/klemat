import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:klemat/custom_level_map/image_params.dart';
import 'package:klemat/custom_level_map/level_map.dart';
import 'package:klemat/custom_level_map/level_map_paramas.dart';
import 'package:klemat/helper.dart';
import 'package:klemat/screens/3_letter_screen.dart';
import 'package:klemat/screens/4_letter_screen.dart';
import 'package:klemat/screens/5_letter_screen.dart';

class LevelMapPage extends StatefulWidget {
  final int currentLevel;
  final String whichMode;

  const LevelMapPage(this.whichMode, {super.key, required this.currentLevel});

  @override
  _LevelMapPageState createState() => _LevelMapPageState();
}

class _LevelMapPageState extends State<LevelMapPage> with RouteAware {
  late int currentLevel;

  @override
  void initState() {
    super.initState();
    currentLevel = widget.currentLevel;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    setState(() {});
  }

  Future<String?> getWordForLevel(String mode, int level) async {
    String path;

    if (mode == "Mode 5") {
      path = 'assets/words/5_letters/5_letter_levels.json';
    } else if (mode == "Mode 4") {
      path = 'assets/words/4_letters/4_letter_levels.json';
    } else {
      path = 'assets/words/3_letters/3_letter_levels.json';
    }

    final jsonString = await rootBundle.loadString(path);
    final data = json.decode(jsonString);
    final levelsList = List<Map<String, dynamic>>.from(data['levels']);
    final match = levelsList.firstWhere(
      (item) => item['level'] == level,
      orElse: () => {},
    );
    return match['word'];
  }

  void _openLevel() async {
    final word = await getWordForLevel(widget.whichMode, widget.currentLevel);
    if (word == null) return;

    Widget screen =
        widget.whichMode == "Mode 5"
            ? FiveLetterScreen(correctWord: word)
            : widget.whichMode == "Mode 4"
            ? FourLetterScreen(correctWord: word)
            : ThreeLetterScreen(correctWord: word);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mode = widget.whichMode;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(backgroundColor: const Color.fromARGB(69, 53, 53, 53), elevation: 0),
        extendBodyBehindAppBar: true,
        body: LevelMap(
          backgroundColor:
              mode == "Mode 5"
                  ? const Color.fromARGB(255, 142, 212, 241)
                  : mode == "Mode 4"
                  ? const Color.fromARGB(255, 255, 201, 120)
                  : const Color.fromARGB(255, 219, 142, 255),
          levelMapParams: LevelMapParams(
            levelCount: 10,
            currentLevel: widget.currentLevel,
            pathColor:
                mode == "Mode 5"
                    ? const Color.fromARGB(255, 5, 102, 143)
                    : mode == "Mode 4"
                    ? const Color.fromARGB(255, 163, 106, 21)
                    : const Color.fromARGB(255, 81, 16, 111),
            currentLevelImage: ImageParams(
              path: "assets/images/green_flag.png",
              size: const Size(40, 47),
              onPressed: _openLevel,
            ),
            lockedLevelImage: ImageParams(
              path: "assets/images/locked_flag.png",
              size: const Size(40, 42),
            ),
            completedLevelImage: ImageParams(
              path: "assets/images/finished_flag.png",
              size: const Size(40, 42),
            ),
            /*bgImagesToBePaintedRandomly: [
              ImageParams(
                path: "assets/images/arab1-removebg-preview.png",
                size: Size(80, 80),
                repeatCountPerLevel: 0.5,
              ),
              ImageParams(
                path: "assets/images/arab2-removebg-preview.png",
                size: Size(80, 80),
                repeatCountPerLevel: 0.25,
              ),
              ImageParams(
                path: "assets/images/arab3-removebg-preview.png",
                size: Size(80, 80),
                repeatCountPerLevel: 0.25,
              ),
            ],*/
          ),
        ),
      ),
    );
  }
}
