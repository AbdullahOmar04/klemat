import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:klemat/custom_level_map/bg_image.dart';
import 'package:klemat/custom_level_map/image_details.dart';
import 'package:klemat/custom_level_map/image_params.dart';
import 'package:klemat/custom_level_map/images_tp_paint.dart';
import 'package:klemat/custom_level_map/level_map_paramas.dart';
import 'package:klemat/custom_level_map/offset_extension.dart';
import 'package:klemat/custom_level_map/side.dart' show Side;

Future<ImagesToPaint?> loadImagesToPaint(
  LevelMapParams levelMapParams,
  int levelCount,
  double levelHeight,
  double screenWidth,
) async {
  final ImageDetails completedLevelImageDetails = ImageDetails(
    imageInfo: await _getUiImage(levelMapParams.completedLevelImage),
    size: levelMapParams.completedLevelImage.size,
  );
  final ImageDetails currentLevelImageDetails = ImageDetails(
    imageInfo: await _getUiImage(levelMapParams.currentLevelImage),
    size: levelMapParams.currentLevelImage.size,
  );
  final ImageDetails lockedLevelImageDetails = ImageDetails(
    imageInfo: await _getUiImage(levelMapParams.lockedLevelImage),
    size: levelMapParams.lockedLevelImage.size,
  );
  final ImageDetails? startLevelImageDetails =
      levelMapParams.startLevelImage != null
          ? ImageDetails(
            imageInfo: await _getUiImage(levelMapParams.startLevelImage!),
            size: levelMapParams.startLevelImage!.size,
          )
          : null;
  final ImageDetails? pathEndImageDetails =
      levelMapParams.pathEndImage != null
          ? ImageDetails(
            imageInfo: await _getUiImage(levelMapParams.pathEndImage!),
            size: levelMapParams.pathEndImage!.size,
          )
          : null;
  final List<BGImage>? bgImageDetailsList =
      levelMapParams.bgImagesToBePaintedRandomly != null
          ? await _getBGImages(
            levelMapParams.bgImagesToBePaintedRandomly!,
            levelCount,
            levelHeight,
            screenWidth,
          )
          : null;
  return ImagesToPaint(
    bgImages: bgImageDetailsList,
    startLevelImage: startLevelImageDetails,
    completedLevelImage: completedLevelImageDetails,
    currentLevelImage: currentLevelImageDetails,
    lockedLevelImage: lockedLevelImageDetails,
    pathEndImage: pathEndImageDetails,
  );
}

// ignore: body_might_complete_normally_nullable
Future<List<BGImage>> _getBGImages(
  List<ImageParams> bgImagesParams,
  int levelCount,
  double levelHeight,
  double screenWidth,
) async {
  final List<BGImage> _bgImagesToPaint = [];
  final math.Random random = math.Random(123); // RESET SEED

  for (final bgImageParam in bgImagesParams) {
    final imageInfo = await _getUiImage(bgImageParam);
    if (bgImageParam.repeatCountPerLevel == 0) {
      continue;
    }
    final offsetList = _getImageOffsets(
      bgImageParam,
      levelCount,
      levelHeight,
      screenWidth,
      random, // pass controlled random
    );
    _bgImagesToPaint.add(
      BGImage(
        imageDetails: ImageDetails(
          imageInfo: imageInfo,
          size: bgImageParam.size,
        ),
        offsetsToBePainted: offsetList,
      ),
    );
  }

  return _bgImagesToPaint;
}

List<ui.Offset> _getImageOffsets(
  ImageParams imageParams,
  int levelCount,
  double levelHeight,
  double screenWidth,
  math.Random random, // pass it here
) {
  final List<ui.Offset> offsetList = [];
  final int imageRepeatCount =
      (levelCount * imageParams.repeatCountPerLevel).ceil();
  final double heightBasedOnRepeatCount =
      (1 / imageParams.repeatCountPerLevel) * levelHeight;

  for (int i = 1; i <= imageRepeatCount; i++) {
    double dx = 0;
    final double _widthPerSide = screenWidth / 2;

    if (imageParams.side == Side.RIGHT ||
        (imageParams.side == Side.BOTH && random.nextBool())) {
      dx =
          imageParams.imagePositionFactor * _widthPerSide * random.nextDouble();
      dx = screenWidth - dx;
    } else {
      dx =
          imageParams.imagePositionFactor * _widthPerSide * random.nextDouble();
    }

    final double dy =
        -(((i - 1) * heightBasedOnRepeatCount) +
            (heightBasedOnRepeatCount * random.nextDouble()));

    offsetList.add(
      ui.Offset(
        dx,
        dy,
      ).clamp(imageParams.size, Size(screenWidth, levelCount * levelHeight)),
    );
  }

  return offsetList;
}

Future<ImageInfo> _getUiImage(ImageParams imageParams) async {
  Completer<ImageInfo> completer = Completer();
  final AssetImage image = AssetImage(imageParams.path);
  image
      .resolve(ImageConfiguration())
      .addListener(
        ImageStreamListener((ImageInfo info, bool _) {
          completer.complete(info);
        }),
      );
  ImageInfo imageInfo = await completer.future;
  return imageInfo;
}
