import 'package:flutter/material.dart';

const BLUE_NORMAL = Color(0xff54c5f8);
const GREEN_NORMAL = Color(0xff6bde54);
const BLUE_DARK2 = Color(0xff01579b);

class BgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = BLUE_NORMAL
      ..isAntiAlias = true;

    var circleCenter = Offset(200, 200);
    paint.color = BLUE_NORMAL;
    canvas.drawCircle(circleCenter, 100, paint);
    paint.color = GREEN_NORMAL;
    canvas.drawCircle(circleCenter, 80, paint);
    paint.color = Colors.white;
    canvas.drawCircle(circleCenter, 50, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    throw UnimplementedError();
  }
}
