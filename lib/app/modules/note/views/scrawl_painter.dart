import 'package:flutter/material.dart';

import '../controllers/note_controller.dart';

/// @Author: kevin
/// @Title: scrawl_painter.dart
/// @Date: 2022-09-22 15:04:46
/// @Description:
class ScrawlPainter extends CustomPainter {
  final List<Point> points;

  ScrawlPainter({
    required this.points,
  });

  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) {
      return;
    }
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    try {
      for (int i = 0; i < points.length; i++) {
        if (points[i].hide) {
          continue;
        }

        List<TouchPoints> curPoints = points[i].points;
        for (int i = 0; i < curPoints.length - 1; i++) {
          if (curPoints[i].points != null && curPoints[i + 1].points != null) {
            canvas.drawLine(curPoints[i].points!, curPoints[i + 1].points!,
                curPoints[i].paint);
            canvas.drawCircle(curPoints[i].points!,
                curPoints[i].paint.strokeWidth / 2, curPoints[i].paint);
          }
        }
      }
    } catch (_) {}
    canvas.restore();
  }

  bool shouldRepaint(ScrawlPainter other) => true;
}

class Point {
  List<TouchPoints> points;
  bool hide;
  CanvasModel canvasModel; // 画笔的类型

  Point({required this.points, required this.hide, required this.canvasModel});
}

class TouchPoints {
  Paint paint;
  Offset? points;

  TouchPoints({this.points, required this.paint});
}

class EditOrder {
  int curFrame;
  CanvasModel canvasModel;

  EditOrder({required this.curFrame, required this.canvasModel});

  // EditOrder.fromJson(Map<String, dynamic> json) {
  //   curFrame = json['curFrame'];
  //   canvasModel = json['canvasModel'];
  // }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['curFrame'] = this.curFrame;
    data['canvasModel'] = this.canvasModel;
    return data;
  }
}
