import 'package:flutter/material.dart';

/// @author Kevin
/// @date 2022/11/9 12:02
/// @desc

class DrawingBoardPainter extends CustomPainter {
  final List<List<Offset>> path;
  final BuildContext context;

  DrawingBoardPainter(this.path, this.context);

  final Paint _paint = Paint()
    ..color = Colors.red
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..strokeWidth = 20;

  @override
  void paint(Canvas canvas, Size size) {
    path.forEach((list) {
      Path _path = Path();
      for (int i = 0; i < list.length; i++) {
        if (i == 0) {
          _path.moveTo(list[i].dx, list[i].dy);
        } else {
          _path.lineTo(list[i].dx, list[i].dy);
        }
      }
      canvas.drawPath(
        _path,
        _paint,
      );
    });
  }

  @override
  bool shouldRepaint(DrawingBoardPainter oldDelegate) {
    return true;
  }
}
