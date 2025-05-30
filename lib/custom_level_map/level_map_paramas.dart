import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'image_params.dart';

class LevelMapParams {
  final int levelCount;
  late final int currentLevel;
  final double pathStrokeWidth;
  final Color pathColor;
  final double levelHeight;
  final double dashLengthFactor;
  final bool enableVariationBetweenCurves;
  final double maxVariationFactor;
  final bool showPathShadow;
  final Offset shadowDistanceFromPathOffset;
  final Offset minReferencePositionOffsetFactor;
  final Offset maxReferencePositionOffsetFactor;
  final List<ImageParams>? bgImagesToBePaintedRandomly;
  final ImageParams? startLevelImage;
  final ImageParams completedLevelImage;
  final ImageParams currentLevelImage;
  final ImageParams lockedLevelImage;
  final ImageParams? pathEndImage;

  late final Offset? firstCurveReferencePointOffsetFactor;
  late final List<Offset> curveReferenceOffsetVariationForEachLevel;

  LevelMapParams({
    required this.levelCount,
    required int currentLevel,
    this.pathColor = Colors.black,
    this.levelHeight = 200,
    this.pathStrokeWidth = 3,
    this.dashLengthFactor = 0.025,
    this.enableVariationBetweenCurves = false,
    this.maxVariationFactor = 0.2,
    this.showPathShadow = true,
    this.shadowDistanceFromPathOffset = const Offset(-2, 12),
    this.minReferencePositionOffsetFactor = const Offset(0.4, 0.3),
    this.maxReferencePositionOffsetFactor = const Offset(1, 0.7),
    Offset? firstCurveReferencePointOffsetFactor,
    this.bgImagesToBePaintedRandomly,
    this.startLevelImage,
    required this.completedLevelImage,
    required this.currentLevelImage,
    required this.lockedLevelImage,
    this.pathEndImage,
  })  : assert(currentLevel <= levelCount),
        assert(currentLevel >= 1),
        assert(dashLengthFactor >= 0 && dashLengthFactor <= 0.5),
        assert(100 % (dashLengthFactor * 100) == 0),
        assert(
          minReferencePositionOffsetFactor.dx >= 0 &&
              minReferencePositionOffsetFactor.dx <= 1 &&
              minReferencePositionOffsetFactor.dy >= 0 &&
              minReferencePositionOffsetFactor.dy <= 1,
        ),
        assert(
          maxReferencePositionOffsetFactor.dx >= 0 &&
              maxReferencePositionOffsetFactor.dx <= 1 &&
              maxReferencePositionOffsetFactor.dy >= 0 &&
              maxReferencePositionOffsetFactor.dy <= 1,
        ) {
    this.currentLevel = currentLevel.clamp(1, levelCount).toInt();

    // Seeded random generator to fix curve layout per level
    final random = math.Random(this.currentLevel + levelCount);

    // Generate curve variation offsets
    curveReferenceOffsetVariationForEachLevel = List.generate(
      levelCount,
      (index) => Offset(
        (random.nextBool() ? random.nextDouble() : -random.nextDouble()) * maxVariationFactor,
        (random.nextBool() ? random.nextDouble() : -random.nextDouble()) * maxVariationFactor,
      ),
      growable: false,
    );

    // Assign initial curve reference point offset
    this.firstCurveReferencePointOffsetFactor =
        firstCurveReferencePointOffsetFactor ?? Offset(random.nextDouble(), random.nextDouble());
  }
}
