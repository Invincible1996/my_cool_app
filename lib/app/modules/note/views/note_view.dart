import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

import '../controllers/note_controller.dart';
import 'draw_screen.dart';
import 'scrawl_painter.dart';

enum LastEditType {
  undo,
  redo,
  clear,
  draw,
}

class NoteView extends StatefulWidget {
  const NoteView({Key? key}) : super(key: key);

  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  /// 上一次编辑的类型
  LastEditType _lastEditType = LastEditType.draw;

  ///
  List<Point> points = [
    Point(
      <TouchPoints>[],
    ),
  ];

  ///
  List<Point> originalPoints = [Point(<TouchPoints>[])];

  var currentCanvasModel = CanvasModel.Paint;

  var curFrame = 0;

  PointerDeviceKind deviceKind = PointerDeviceKind.mouse;

  var _leftOffset = 100.0;

  var _topOffset = 100.0;

  bool _showCircle = false;

  Offset _startOffset = Offset(0, 0);
  Offset _endOffset = Offset(0, 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NoteView'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      currentCanvasModel = CanvasModel.Paint;
                    });
                  },
                  child: const Text('笔画'),
                ),
                const SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      currentCanvasModel = CanvasModel.Eraser;
                    });
                  },
                  child: const Text('橡皮'),
                ),
                const SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      currentCanvasModel = CanvasModel.ClearLine;
                    });
                  },
                  child: const Text('清楚指定画笔'),
                ),
                const SizedBox(
                  width: 20,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    undo();
                  },
                  icon: const Icon(Icons.undo_outlined),
                  label: const Text('撤销'),
                ),
                const SizedBox(
                  width: 20,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    redo();
                  },
                  icon: const Icon(Icons.redo_outlined),
                  label: const Text('还原'),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
              child: Stack(
            children: [
              _buildCanvas(),
              _showCircle
                  ? Positioned(
                      left: _leftOffset,
                      top: _topOffset,
                      child: Listener(
                        onPointerMove: (PointerEvent event) {
                          setState(() {
                            _topOffset += event.delta.dy;
                            _leftOffset += event.delta.dx;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                width: 1, color: const Color(0xFF9C9C9C)),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink()
            ],
          )),
        ],
      ),
      // body: Draw(),
    );
  }

  Widget _buildCanvas() {
    return StatefulBuilder(builder: (context, state) {
      return GestureDetector(
        onTapDown: ((details) {
          _onTapDown(context, details);
        }),
        child: CustomPaint(
          painter: ScrawlPainter(
            points: points,
          ),
          child: Listener(
            onPointerDown: (PointerEvent event) {
              _onPointerDown(event);
            },
            onPointerCancel: (PointerEvent event) {
              _onPointerCancel(event);
            },
            onPointerMove: (PointerEvent event) {
              _onPointerMove(event, state);
            },
            onPointerUp: (PointerEvent event) {
              _onPointerUp(event);
            },
            child: Container(
              // height: Application.screenHeight,
              // width: Application.screenWidth,
              color: Colors.transparent,
            ),
          ),
        ),
      );
    });
  }

  /// @desc 按下
  void _onTapDown(BuildContext context, TapDownDetails details) {
    if (currentCanvasModel == CanvasModel.ClearLine) {
      _lastEditType = LastEditType.clear;
      // 显示擦除的圆圈
      _showCircle = true;
      RenderBox box = context.findRenderObject() as RenderBox;
      final offset = box.globalToLocal(details.globalPosition);
      for (var i = 0; i < points.length; i++) {
        var e = points[i];
        for (var e2 in e.points) {
          if (e2.points != null) {
            if ((e2.points! - offset).distance <= 10) {
              print('删除轨迹=======$i');
              curFrame = i;
              points.removeAt(i);

              break;
            }
          }
        }
      }
      setState(() {});
    }
  }

  ///
  ///
  /// @desc 撤销
  undo() {
    print(_lastEditType);
    print(curFrame);
    if (_lastEditType == LastEditType.clear) {
      // 还原
      points.insert(curFrame, originalPoints[curFrame]);
    } else {
      if (curFrame == 0) {
        showToast("没有可撤销的了");
        return;
      }
      curFrame--;
      points.removeAt(curFrame);

      print(points[curFrame].points.first.paint.color);

      // points
      //     .map(
      //       (e) => TouchPoints(
      //         paint: Paint()
      //           ..color = Colors.transparent
      //           ..strokeWidth = 5
      //           ..style = PaintingStyle.fill
      //           ..blendMode = BlendMode.clear
      //           ..isAntiAlias = true,
      //       ),
      //     )
      //     .toList();
    }
  }

  ///
  ///
  /// @desc 还原
  redo() {
    if (originalPoints.length == points.length) {
      showToast("没有可还原的了");
      return;
    } else {
      points.insert(curFrame, originalPoints[curFrame]);
      curFrame++;
    }
  }

  void _onPointerCancel(PointerEvent event) {
    // controller.removePointer(event.pointer);
  }

  /// 手指移动
  void _onPointerMove(PointerEvent event, StateSetter state) {
    // print(event.localPosition);
    addPoints(event.localPosition);
    _leftOffset = event.localPosition.dx - 20;
    _topOffset = event.localPosition.dy - 20;
    setState(() {});
    // if (event.kind == controller.deviceKind) {
    //   if (controller.pointerList.length <= 1) {
    //     controller.addPoints(event.localPosition);
    //     if (controller.currentCanvasModel == CanvasModel.Paint) {
    //     } else if (controller.currentCanvasModel == CanvasModel.Eraser) {
    //       controller.addPoints(event.localPosition);
    //     }
    //   }
    // }
  }

  void addPoints(Offset? offset) {
    if (currentCanvasModel == CanvasModel.Eraser) {
      points[curFrame].points.add(TouchPoints(
            points: offset!,
            paint: Paint()
              ..color = Colors.transparent
              ..strokeWidth = 5
              ..style = PaintingStyle.fill
              ..blendMode = BlendMode.clear
              ..isAntiAlias = true,
          ));
    } else if (currentCanvasModel == CanvasModel.Paint) {
      points[curFrame].points.add(TouchPoints(
            points: offset,
            paint: Paint()
              ..color = Colors.red
              ..strokeWidth = 5
              ..strokeCap = StrokeCap.round
              ..style = PaintingStyle.fill
              ..blendMode = BlendMode.src
              ..isAntiAlias = true,
          ));
    }
    if (offset == null) {
      points.add(Point([TouchPoints(points: offset, paint: Paint())]));
    }
    setState(() {});
  }

  increaseCurFrame() {
    curFrame++;
    setState(() {});
  }

  void updateOriginalPoints() {
    originalPoints.clear();
    originalPoints.addAll(points);
  }

  /// 手指抬起
  void _onPointerUp(PointerEvent event) {
    // controller.removePointer(event.pointer);
    // controller.pointerList.add(null);

    _endOffset = event.localPosition;

    if ((_endOffset - _startOffset).distance <= 0.5) return;

    if (event.kind == deviceKind) {
      if (currentCanvasModel == CanvasModel.Paint) {
        addPoints(null);
        updateOriginalPoints();
        increaseCurFrame();
      } else if (currentCanvasModel == CanvasModel.Eraser) {
        updateOriginalPoints();
        addPoints(null);
        increaseCurFrame();
      }
      print(points);
      setState(() {
        _showCircle = false;
      });
      _lastEditType = LastEditType.draw;
    }

    // if (controller.currentCanvasModel == CanvasModel.Text) {
    //   controller.hideTextField();
    // }
  }

  /// 手指按下
  void _onPointerDown(PointerEvent event) {
    _startOffset = event.localPosition;

    if (currentCanvasModel == CanvasModel.ClearLine) {
      setState(() {
        _showCircle = true;
        _leftOffset = event.localPosition.dx - 20;
        _topOffset = event.localPosition.dy - 20;
      });
    }

    if (currentCanvasModel == CanvasModel.Paint) {
      curFrame = points.length - 1;
    }

    // controller.hideTips();
    // controller.addPointer(event.pointer);
    // controller.isClear = false;
    // controller.initPaint();
    // controller.focusNode.unfocus();
  }
}
