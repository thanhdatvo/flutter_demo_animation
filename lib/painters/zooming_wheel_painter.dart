import 'dart:math';
import 'package:flutter/material.dart';

class ZoomingWheelPainter extends CustomPainter {
  ZoomingWheelPainter() : super();

  double degreeToRadians(double degrees) => degrees * (pi / 180);
  double radianToDegrees(double radians) => radians * (180 / pi);

  @override
  void paint(Canvas canvas, Size size) {
    double radius = 100;

    double halfHypotenuseLength = 26;
    double baseDegree = 45;
    var path = Path();
    for (double i = 0; i <= 360; i++) {
      if (i % 60 == 0) {
        Paint circlePaint = Paint()
          ..color = Colors.redAccent.withOpacity(i.abs() / 720 / 2)
          ..style = PaintingStyle.fill;

        double x = radius * cos(degreeToRadians(i));
        double y = radius * sin(degreeToRadians(i));
        path.moveTo(x + cos(degreeToRadians(baseDegree)) * halfHypotenuseLength,
            y + sin(degreeToRadians(baseDegree)) * halfHypotenuseLength);
        path.lineTo(
            x + cos(degreeToRadians(baseDegree + 90)) * halfHypotenuseLength,
            y + sin(degreeToRadians(baseDegree + 90)) * halfHypotenuseLength);
        path.lineTo(
            x + cos(degreeToRadians(baseDegree + 180)) * halfHypotenuseLength,
            y + sin(degreeToRadians(baseDegree + 180)) * halfHypotenuseLength);
        path.lineTo(
            x + cos(degreeToRadians(baseDegree + 270)) * halfHypotenuseLength,
            y + sin(degreeToRadians(baseDegree + 270)) * halfHypotenuseLength);
        path.close();
        canvas.drawPath(path, circlePaint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
