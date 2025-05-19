import 'package:flutter/material.dart';
import 'package:klemat/custom_level_map/gesture_area_handler.dart';
import 'package:klemat/custom_level_map/images_tp_paint.dart';
import 'package:klemat/custom_level_map/level_map_painter.dart';
import 'package:klemat/custom_level_map/level_map_paramas.dart';
import 'package:klemat/custom_level_map/load_ui_image.dart';
import 'package:klemat/custom_level_map/scroll.dart';

class LevelMap extends StatelessWidget {
  final LevelMapParams levelMapParams;
  final Color backgroundColor;

  /// If set to false, scroll starts from the bottom end (level 1).
  final bool scrollToCurrentLevel;
  const LevelMap({
    Key? key,
    required this.levelMapParams,
    this.backgroundColor = Colors.transparent,
    this.scrollToCurrentLevel = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      
      builder: (context, constraints) => ScrollConfiguration(
        behavior: const MyBehavior(),
        child: SingleChildScrollView(
          controller: ScrollController(
            initialScrollOffset:
                (((scrollToCurrentLevel
                        ? (levelMapParams.levelCount -
                            levelMapParams.currentLevel +
                            2)
                        : levelMapParams.levelCount)) *
                    levelMapParams.levelHeight) -
                constraints.maxHeight,
          ),
          // physics: FixedExtentScrollPhysics(),
          child: ColoredBox(
            color: backgroundColor,
            child: FutureBuilder<ImagesToPaint?>(
              future: loadImagesToPaint(
                levelMapParams,
                levelMapParams.levelCount,
                levelMapParams.levelHeight,
                constraints.maxWidth,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox(
                    height: 200, // placeholder height
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                // Calculate level positions and create tap regions
                final levelPositions = _calculateLevelPositions(
                  levelMapParams,
                  constraints.maxWidth,
                );

                return Stack(
                  children: [
                    CustomPaint(
                      size: Size(
                        constraints.maxWidth,
                        levelMapParams.levelCount * levelMapParams.levelHeight,
                      ),
                      painter: LevelMapPainter(
                        params: levelMapParams,
                        imagesToPaint: snapshot.data!,
                      ),
                    ),
                    // Add gesture detector layer
                    GestureAreaHandler(
                      size: Size(
                        constraints.maxWidth,
                        levelMapParams.levelCount * levelMapParams.levelHeight,
                      ),
                      gestureAreas: levelPositions,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  List<GestureArea> _calculateLevelPositions(
      LevelMapParams params, double width) {
    final List<GestureArea> areas = [];
    final double centerWidth = width / 2;
    final double imageWidth = params.currentLevelImage.size.width;
    final double imageHeight = params.currentLevelImage.size.height;
    
    // Calculate the path positions like the painter does
    final int currentLevel = params.currentLevel;
    
    // Debug areas that cover more of the path - creating multiple gesture areas along the path
    // to ensure we catch the right position
    for (int i = 0; i < params.levelCount; i++) {
      final double y = (params.levelCount - i - 1) * params.levelHeight + (params.levelHeight / 2);
      
      // Create a wider gesture area along the path
      final double tapMargin = 30.0; // Extra tap margin to make it easier to hit
      
      // Add larger hit area for the current level's green circle
      if (i + 1 == currentLevel) {
        areas.add(
          GestureArea(
            rect: Rect.fromLTWH(
              centerWidth - imageWidth/2 - tapMargin,
              y - imageHeight/2 - tapMargin,
              imageWidth + (tapMargin * 2),
              imageHeight + (tapMargin * 2),
            ),
            onTap: params.currentLevelImage.onPressed,
          ),
        );
        
        // Debug logging
        print("Added gesture area for green circle at: ${centerWidth}, $y");
      }
    }
    
    // Add detection areas for the curve path segments
    // This helps catch taps that might be slightly off from the exact circle position
    for (int i = 0; i < params.levelCount - 1; i++) {
      if (i + 1 == currentLevel - 1 || i + 1 == currentLevel) {
        // Add hit areas for segments before and after current level
        final double y1 = (params.levelCount - i - 1) * params.levelHeight + (params.levelHeight / 2);
        final double y2 = (params.levelCount - i - 2) * params.levelHeight + (params.levelHeight / 2);
        
        areas.add(
          GestureArea(
            rect: Rect.fromLTWH(
              centerWidth - 25,
              y2,
              50,
              y1 - y2,
            ),
            onTap: i + 1 == currentLevel - 1 ? params.currentLevelImage.onPressed : null,
          ),
        );
      }
    }

    return areas;
  }
}
