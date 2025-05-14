import 'package:flutter/material.dart';
import 'package:klemat/custom_level_map/image_params.dart';
import 'package:klemat/custom_level_map/level_map.dart';
import 'package:klemat/custom_level_map/level_map_paramas.dart';
import 'package:klemat/helper.dart';
import 'package:klemat/screens/5_letter_screen.dart';

class LevelMapPage extends StatefulWidget {
  const LevelMapPage(int currentFiveModeLevel, {super.key});

  @override
  _LevelMapPageState createState() => _LevelMapPageState();
}

class _LevelMapPageState extends State<LevelMapPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: LevelMap(
          backgroundColor: const Color.fromARGB(255, 255, 201, 201),
          levelMapParams: LevelMapParams(
            levelCount: 10,
            currentLevel: currentFiveModeLevel,
            pathColor: const Color.fromARGB(255, 239, 33, 33),
            currentLevelImage: ImageParams(
              path: "assets/images/locked.png",
              size: Size(40, 47),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FiveLetterScreen()),
                );
              },
            ),
            lockedLevelImage: ImageParams(
              path: "assets/images/locked.png",
              size: Size(40, 42),
            ),
            completedLevelImage: ImageParams(
              path: "assets/images/locked.png",
              size: Size(40, 42),
            ),
            startLevelImage: ImageParams(
              path: "assets/images/locked.png",
              size: Size(60, 60),
            ),
            pathEndImage: ImageParams(
              path: "assets/images/locked.png",
              size: Size(60, 60),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          child: Icon(Icons.bolt, color: Colors.white),
          onPressed: () {
            setState(() {
              //Just to visually see the change of path's curve.
            });
          },
        ),
      ),
    );
  }
}
