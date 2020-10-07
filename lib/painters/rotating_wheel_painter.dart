import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_demo_animation/utils/number_utils.dart';

class RotatingWheelPainter extends CustomPainter {
  double diameter;
  double radius;
  final degree;
  BuildContext context;

  RotatingWheelPainter(this.degree, {this.diameter, @required this.context}) {
    radius = diameter / 2;
  }

  @override
  void paint(Canvas canvas, Size size) {
    double halfHypotenuseLength = 25;
    double baseDegree = 45 - degree;

    for (double i = 0; i <= 360; i++) {
      if (i % 36 == 0) {
        final path = Path();
        Paint circlePaint = Paint()
          ..color = Colors.green.withOpacity(i.abs() / 360)
          ..style = PaintingStyle.fill;

        double x = radius * cos(NumberUtils.degreeToRadians(i));
        double y = radius * sin(NumberUtils.degreeToRadians(i));
        path.moveTo(
            x +
                cos(NumberUtils.degreeToRadians(baseDegree)) *
                    halfHypotenuseLength,
            y +
                sin(NumberUtils.degreeToRadians(baseDegree)) *
                    halfHypotenuseLength);
        path.lineTo(
            x +
                cos(NumberUtils.degreeToRadians(baseDegree + 90)) *
                    halfHypotenuseLength,
            y +
                sin(NumberUtils.degreeToRadians(baseDegree + 90)) *
                    halfHypotenuseLength);
        path.lineTo(
            x +
                cos(NumberUtils.degreeToRadians(baseDegree + 180)) *
                    halfHypotenuseLength,
            y +
                sin(NumberUtils.degreeToRadians(baseDegree + 180)) *
                    halfHypotenuseLength);
        path.lineTo(
            x +
                cos(NumberUtils.degreeToRadians(baseDegree + 270)) *
                    halfHypotenuseLength,
            y +
                sin(NumberUtils.degreeToRadians(baseDegree + 270)) *
                    halfHypotenuseLength);
        path.close();
        canvas.drawPath(path, circlePaint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
