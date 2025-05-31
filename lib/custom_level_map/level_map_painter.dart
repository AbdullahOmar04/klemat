import 'dart:math';
import 'package:flutter/material.dart';
import 'package:klemat/custom_level_map/image_details.dart';
import 'package:klemat/custom_level_map/images_tp_paint.dart';
import 'package:klemat/custom_level_map/level_map_paramas.dart';
import 'package:klemat/custom_level_map/offset_extension.dart';

class LevelMapPainter extends CustomPainter {
  final LevelMapParams params;
  final ImagesToPaint? imagesToPaint;
  final Paint _pathPaint;
  final Paint _shadowPaint;
  final int _nextLevelFraction;

  LevelMapPainter({
    required this.params,
    this.imagesToPaint,
  })  : _pathPaint = Paint()
          ..strokeWidth = params.pathStrokeWidth
          ..color = params.pathColor
          ..strokeCap = StrokeCap.round,
        _shadowPaint = Paint()
          ..strokeWidth = params.pathStrokeWidth
          ..color = params.pathColor.withOpacity(0.2)
          ..strokeCap = StrokeCap.round,
        _nextLevelFraction =
            params.currentLevel - params.currentLevel.floor();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(0, size.height);

    if (imagesToPaint != null) {
      _drawBGImages(canvas);
      _drawStartLevelImage(canvas, size.width);
      _drawPathEndImage(canvas, size.width, size.height);
    }

    final centerX = size.width / 2;
    final initOff = params.firstCurveReferencePointOffsetFactor
        ?? const Offset(0.5, 0.5);
    double dxVar = initOff.dx;
    double dyVar = initOff.dy;

    for (int idx = 0; idx < params.levelCount; idx++) {
      final p1 = Offset(centerX, -idx * params.levelHeight);
      final p2 = getP2OffsetBasedOnCurveSide(
        idx, dxVar, dyVar, centerX,
      );
      final p3 = Offset(
        centerX,
        -((idx * params.levelHeight) + params.levelHeight),
      );

      _drawBezierCurve(canvas, p1, p2, p3, idx + 1);

      if (params.enableVariationBetweenCurves) {
        dxVar +=
            params.curveReferenceOffsetVariationForEachLevel[idx].dx;
        dyVar +=
            params.curveReferenceOffsetVariationForEachLevel[idx].dy;
      }
    }

    canvas.restore();
  }

  void _drawBGImages(Canvas canvas) {
    final bg = imagesToPaint!.bgImages;
    if (bg != null) {
      for (var b in bg) {
        for (var off in b.offsetsToBePainted) {
          _paintImage(canvas, b.imageDetails, off);
        }
      }
    }
  }

  void _drawStartLevelImage(Canvas canvas, double w) {
    final img = imagesToPaint!.startLevelImage;
    if (img != null) {
      _paintImage(
        canvas,
        img,
        Offset(w / 2, 0).toBottomCenter(img.size),
      );
    }
  }

  void _drawPathEndImage(
      Canvas canvas, double w, double h) {
    final img = imagesToPaint!.pathEndImage;
    if (img != null) {
      _paintImage(
        canvas,
        img,
        Offset(w / 2, -h).toTopCenter(img.size.width),
      );
    }
  }

  Offset getP2OffsetBasedOnCurveSide(
    int thisLevel,
    double dxVar,
    double dyVar,
    double centerW,
  ) {
    final dxClamped = dxVar.clamp(
      params.minReferencePositionOffsetFactor.dx,
      params.maxReferencePositionOffsetFactor.dx,
    );
    final dyClamped = dyVar.clamp(
      params.minReferencePositionOffsetFactor.dy,
      params.maxReferencePositionOffsetFactor.dy,
    );

    final dx = thisLevel.isEven
        ? centerW * (1 - dxClamped)
        : centerW + (centerW * dxClamped);
    final dy = -((thisLevel * params.levelHeight) +
        (params.levelHeight *
            (thisLevel.isEven ? dyClamped : 1 - dyClamped)));

    return Offset(dx, dy);
  }

  void _drawBezierCurve(
    Canvas canvas,
    Offset p1,
    Offset p2,
    Offset p3,
    int thisLevel,
  ) {
    // dashed path
    final dash = params.dashLengthFactor;
    for (double t = dash; t <= 1; t += dash * 2) {
      final o1 = Offset(
        _compute(t, p1.dx, p2.dx, p3.dx),
        _compute(t, p1.dy, p2.dy, p3.dy),
      );
      final o2 = Offset(
        _compute(t + dash, p1.dx, p2.dx, p3.dx),
        _compute(t + dash, p1.dy, p2.dy, p3.dy),
      );
      canvas.drawLine(o1, o2, _pathPaint);
      if (params.showPathShadow) {
        canvas.drawLine(
          o1.translate(
            params.shadowDistanceFromPathOffset.dx,
            params.shadowDistanceFromPathOffset.dy,
          ),
          o2.translate(
            params.shadowDistanceFromPathOffset.dx,
            params.shadowDistanceFromPathOffset.dy,
          ),
          _shadowPaint,
        );
      }
    }

    if (imagesToPaint == null) return;

    // midpoint of this segment
    final mid = Offset(
      _compute(0.5, p1.dx, p2.dx, p3.dx),
      _compute(0.5, p1.dy, p2.dy, p3.dy),
    );

    // pick base icon
    final baseImg = params.currentLevel >= thisLevel
        ? imagesToPaint!.completedLevelImage
        : imagesToPaint!.lockedLevelImage;

    // draw the node
    _paintImage(canvas, baseImg, mid.toBottomCenter(baseImg.size));

    // maybe draw the “current” icon
    final fl = params.currentLevel.floor();
    if ((fl == thisLevel && _nextLevelFraction <= 0.5) ||
        (fl == thisLevel - 1 && _nextLevelFraction > 0.5)) {
      final frac = fl == thisLevel
          ? 0.5 + _nextLevelFraction
          : _nextLevelFraction - 0.5;
      final pos = Offset(
        _compute(frac, p1.dx, p2.dx, p3.dx),
        _compute(frac, p1.dy, p2.dy, p3.dy),
      );
      final cur = imagesToPaint!.currentLevelImage;
      _paintImage(canvas, cur, pos.toBottomCenter(cur.size));
    }

    // ── Improved level number styling ──
    final levelText = '$thisLevel';
    final tp = TextPainter(
      text: TextSpan(
        text: levelText,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // circle diameter (slightly larger than text)
    final dia = max(tp.width, tp.height) + 8;
    // circle center sits just right of the node icon
    final cx = mid.dx + baseImg.size.width / 2 + dia / 2 + 4;
    final cy = mid.dy;

    // filled circle
    canvas.drawCircle(
      Offset(cx, cy),
      dia / 2,
      Paint()..color = params.pathColor.withOpacity(0.9),
    );
    // border
    canvas.drawCircle(
      Offset(cx, cy),
      dia / 2,
      Paint()
        ..color = params.pathColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    // text centered in the circle
    tp.paint(
      canvas,
      Offset(cx - tp.width / 2, cy - tp.height / 2),
    );
  }

  void _paintImage(
    Canvas canvas,
    ImageDetails imageDetails,
    Offset offset,
  ) {
    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(
        offset.dx,
        offset.dy,
        imageDetails.size.width,
        imageDetails.size.height,
      ),
      image: imageDetails.imageInfo.image,
    );
  }

  double _compute(double t, double p1, double p2, double p3) {
    return (1 - t) * (1 - t) * p1 +
        2 * (1 - t) * t * p2 +
        t * t * p3;
  }

  @override
  bool shouldRepaint(covariant LevelMapPainter old) =>
      old.imagesToPaint != imagesToPaint ||
      old.params.currentLevel != params.currentLevel;
}
