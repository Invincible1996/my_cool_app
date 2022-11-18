import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../views/scrawl_painter.dart';

enum CanvasModel {
  Paint, //画笔
  Eraser, // 橡皮擦
  ClearLine, // 笔画橡皮擦
}

class NoteController extends GetxController {
  PointerDeviceKind deviceKind = PointerDeviceKind.touch;

  var pointerList = [].obs;

  var currentCanvasModel = CanvasModel.Paint;

  var points = [].obs;

  var curFrame = 0.obs;

  void removePointer(int pointer) {}

  void addPoints(Offset? offset) {
    if (currentCanvasModel == CanvasModel.Eraser) {
      points[curFrame.value].points.add(TouchPoints(
            points: offset!,
            paint: Paint()
              ..color = Colors.transparent
              ..strokeWidth = 10
              ..style = PaintingStyle.fill
              ..blendMode = BlendMode.clear
              ..isAntiAlias = true,
          ));
    } else if (currentCanvasModel == CanvasModel.Paint) {
      points[curFrame.value].points.add(TouchPoints(
            points: offset!,
            paint: Paint()
              ..color = Colors.red
              ..strokeWidth = 10
              ..strokeCap = StrokeCap.round
              ..style = PaintingStyle.fill
              ..blendMode = BlendMode.src
              ..isAntiAlias = true,
          ));
    }
    if (offset == null) {
      points.add(Point(
        points: [TouchPoints(points: offset!, paint: Paint())],
        hide: false,
        canvasModel: CanvasModel.Paint,
      ));
    }
  }

  void increaseCurFrame() {
    curFrame++;
  }
}
