import 'package:flutter/material.dart';
import 'dart:math';

class SimplerCustomLoader extends StatefulWidget {
  final Color color1;
  final Color color2;

  const SimplerCustomLoader({
    super.key,
    this.color1 = Colors.amber,
    this.color2 = Colors.blue,
  });

  @override
  State<SimplerCustomLoader> createState() => _SimplerCustomLoaderState();
}

class _SimplerCustomLoaderState extends State<SimplerCustomLoader> with TickerProviderStateMixin {
  late Animation<double> animation1;
  late Animation<double> animation2;

  late AnimationController controller1;
  late AnimationController controller2;

  @override
  void initState() {
    super.initState();
    controller1 = AnimationController(duration: const Duration(milliseconds: 2500), vsync: this);

    controller2 = AnimationController(duration: const Duration(milliseconds: 2500), vsync: this);

    animation1 = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: controller1, curve: const Interval(0.0, 1.0, curve: Curves.bounceIn)));

    animation2 = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: controller2, curve: const Interval(0.0, 1.0, curve: Curves.linear)));

    controller1.repeat();
    controller2.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: <Widget>[
          RotationTransition(
            turns: animation1,
            child: CustomPaint(
              painter: Arc1Painter(widget.color1),
              child: const SizedBox(
                width: 35.0,
                height: 35.0,
              ),
            ),
          ),
          RotationTransition(
            turns: animation2,
            child: CustomPaint(
              painter: Arc2Painter(widget.color2),
              child: const SizedBox(
                width: 35.0,
                height: 35.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller1.dispose();
    controller2.dispose();
    super.dispose();
  }
}

class Arc1Painter extends CustomPainter {
  final Color color;

  Arc1Painter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    Paint p1 = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    Rect rect1 = Rect.fromLTWH(0.0, 0.0, size.width, size.height);

    canvas.drawArc(rect1, 0.0, 0.3 * pi, false, p1);
    canvas.drawArc(rect1, 0.5 * pi, 0.3 * pi, false, p1);
    canvas.drawArc(rect1, 1.0 * pi, 0.3 * pi, false, p1);
    canvas.drawArc(rect1, 1.5 * pi, 0.3 * pi, false, p1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class Arc2Painter extends CustomPainter {
  final Color color;

  Arc2Painter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    Paint p2 = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    Rect rect2 = Rect.fromLTWH(0.0 + (0.5 * size.width) / 2, 0.0 + (0.5 * size.height) / 2,
        size.width - 0.5 * size.width, size.height - 0.5 * size.height);

    canvas.drawArc(rect2, 0.0, 0.8 * pi, false, p2);
    canvas.drawArc(rect2, 1.0 * pi, 0.8 * pi, false, p2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
