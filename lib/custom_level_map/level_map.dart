import 'package:flutter/material.dart';
import 'package:klemat/custom_level_map/gesture_area_handler.dart';
import 'package:klemat/custom_level_map/images_tp_paint.dart';
import 'package:klemat/custom_level_map/level_map_painter.dart';
import 'package:klemat/custom_level_map/level_map_paramas.dart';
import 'package:klemat/custom_level_map/load_ui_image.dart';
import 'package:klemat/custom_level_map/scroll.dart';

class LevelMap extends StatefulWidget {
  final LevelMapParams levelMapParams;
  final Color backgroundColor;
  final bool scrollToCurrentLevel;

  const LevelMap({
    Key? key,
    required this.levelMapParams,
    this.backgroundColor = Colors.transparent,
    this.scrollToCurrentLevel = true,
  }) : super(key: key);

  @override
  _LevelMapState createState() => _LevelMapState();
}

class _LevelMapState extends State<LevelMap> {
  late final ScrollController _scrollController;
  bool _hasScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => ScrollConfiguration(
        behavior: const MyBehavior(),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: ColoredBox(
            color: widget.backgroundColor,
            child: FutureBuilder<ImagesToPaint?>(
              future: loadImagesToPaint(
                widget.levelMapParams,
                widget.levelMapParams.levelCount,
                widget.levelMapParams.levelHeight,
                constraints.maxWidth,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                // ── scroll only once, after we have laid out the children ──
                if (widget.scrollToCurrentLevel && !_hasScrolled) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    final p = widget.levelMapParams;
                    final viewport = constraints.maxHeight;
                    final rawOffset = ((p.levelCount - p.currentLevel + 2)
                            * p.levelHeight) -
                        viewport;
                    final maxScroll =
                        _scrollController.position.maxScrollExtent;
                    final target = rawOffset.clamp(0.0, maxScroll);
                    _scrollController.jumpTo(target);
                    _hasScrolled = true;
                  });
                }

                final hitAreas = _calculateLevelPositions(
                  widget.levelMapParams,
                  constraints.maxWidth,
                );

                return Stack(
                  children: [
                    CustomPaint(
                      size: Size(
                        constraints.maxWidth,
                        widget.levelMapParams.levelCount *
                            widget.levelMapParams.levelHeight,
                      ),
                      painter: LevelMapPainter(
                        params: widget.levelMapParams,
                        imagesToPaint: snapshot.data!,
                      ),
                    ),
                    GestureAreaHandler(
                      size: Size(
                        constraints.maxWidth,
                        widget.levelMapParams.levelCount *
                            widget.levelMapParams.levelHeight,
                      ),
                      gestureAreas: hitAreas,
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
    final centerX = width / 2;
    final imgW = params.currentLevelImage.size.width;
    final imgH = params.currentLevelImage.size.height;
    const tapPad = 30.0;
    final lvl = params.currentLevel;

    // Current-level tap zone
    for (int i = 0; i < params.levelCount; i++) {
      if (i + 1 == lvl) {
        final y = (params.levelCount - i - 1) * params.levelHeight +
            params.levelHeight / 2;
        areas.add(GestureArea(
          rect: Rect.fromLTWH(
            centerX - imgW / 2 - tapPad,
            y - imgH / 2 - tapPad,
            imgW + tapPad * 2,
            imgH + tapPad * 2,
          ),
          onTap: params.currentLevelImage.onPressed,
        ));
      }
    }

    // Path segments around the current node
    for (int i = 0; i < params.levelCount - 1; i++) {
      if (i + 1 == lvl - 1 || i + 1 == lvl) {
        final y1 = (params.levelCount - i - 1) * params.levelHeight +
            params.levelHeight / 2;
        final y2 = (params.levelCount - i - 2) * params.levelHeight +
            params.levelHeight / 2;
        areas.add(GestureArea(
          rect: Rect.fromLTWH(centerX - 25, y2, 50, y1 - y2),
          onTap: i + 1 == lvl - 1 ? params.currentLevelImage.onPressed : null,
        ));
      }
    }

    return areas;
  }
}
