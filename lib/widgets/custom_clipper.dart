import 'package:flutter/material.dart';

class OverlayWithRectangleClipping extends StatelessWidget {
  const OverlayWithRectangleClipping({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.transparent, body: _getCustomPaintOverlay(context));
  }

  //CustomPainter that helps us in doing this
  Widget _getCustomPaintOverlay(BuildContext context) {
    return CustomPaint(
      size: MediaQuery.of(context).size,
      painter: RectanglePainter(),
    );
  }
}

class RectanglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black54;
    final borderPaint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    var rect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.40),
      width: size.width * 0.9,
      height: size.height * 0.3,
    );

    canvas.drawPath(
      Path.combine(
        PathOperation.difference, //simple difference of following operations
        //bellow draws a rectangle of full screen (parent) size
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        //bellow clips out the circular rectangle with center as offset and dimensions you need to set
        Path()
          ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(16)))
          ..close(),
      ),
      paint,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(16)), borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
