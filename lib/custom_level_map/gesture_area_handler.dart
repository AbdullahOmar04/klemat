import 'package:flutter/material.dart';

class GestureAreaHandler extends StatefulWidget {
  final Size size;
  final List<GestureArea> gestureAreas;

  const GestureAreaHandler({
    super.key,
    required this.size,
    required this.gestureAreas,
  });

  @override
  _GestureAreaHandlerState createState() => _GestureAreaHandlerState();
}

class _GestureAreaHandlerState extends State<GestureAreaHandler> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size.width,
      height: widget.size.height,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (TapDownDetails details) {
          final RenderBox box = context.findRenderObject() as RenderBox;
          final Offset localPosition = box.globalToLocal(details.globalPosition);
          
          for (final area in widget.gestureAreas) {
            if (area.rect.contains(localPosition) && area.onTap != null) {
              area.onTap!();
              break;
            }
          }
        },
        child: Container(
          color: Colors.transparent,
          // Uncomment for debugging gesture areas
          // child: CustomPaint(
          //   painter: GestureAreaDebugPainter(widget.gestureAreas),
          // ),
        ),
      ),
    );
  }
}

class GestureArea {
  final Rect rect;
  final VoidCallback? onTap;

  GestureArea({required this.rect, this.onTap});
}

// Uncomment for debugging - shows the clickable areas
// class GestureAreaDebugPainter extends CustomPainter {
//   final List<GestureArea> areas;
//   
//   GestureAreaDebugPainter(this.areas);
//   
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.red.withOpacity(0.3)
//       ..style = PaintingStyle.fill;
//       
//     for (final area in areas) {
//       canvas.drawRect(area.rect, paint);
//     }
//   }
//   
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }
