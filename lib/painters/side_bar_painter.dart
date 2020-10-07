import 'package:flutter/material.dart';

class SideBarPainter extends CustomPainter {
  final double curveRatio;
  SideBarPainter(this.curveRatio);
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();

    var middleVertical = size.height / 2;
    var lineWidth = 20;
    var dx = size.width - lineWidth;
    paint.color = Colors.green.withOpacity(0.3);
    paint.style = PaintingStyle.fill; // Change this to fill

    var path = Path();
    var radius = 160 * curveRatio;
    var distance1 = 100 * curveRatio;
    var distance2 = 30 * curveRatio;

    path.moveTo(size.width, 0);
    path.lineTo(dx, 0);
    path.lineTo(dx, middleVertical - radius - distance1);

    path.quadraticBezierTo(dx, middleVertical - radius - distance2,
        dx - distance2, middleVertical - radius);
    path.quadraticBezierTo(dx - radius * 1.4, middleVertical, dx - distance2,
        middleVertical + radius);
    path.quadraticBezierTo(dx, middleVertical + radius + distance2, dx,
        middleVertical + radius + distance1);

    path.lineTo(dx, size.height);
    path.lineTo(size.width, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
