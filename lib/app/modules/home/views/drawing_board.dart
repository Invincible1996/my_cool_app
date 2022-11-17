import 'package:flutter/material.dart';

import 'drawing_board_painter.dart';

/// @author Kevin
/// @date 2022/11/9 12:02
/// @desc

class DrawingBoard extends StatefulWidget {
  const DrawingBoard({super.key});

  @override
  _DrawingBoardState createState() => _DrawingBoardState();
}

class _DrawingBoardState extends State<DrawingBoard> {
  List<List<Offset>> _path = [];

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent pointerDownEvent) {
        setState(() {
          _path.add([pointerDownEvent.localPosition]);
        });
      },
      onPointerMove: (PointerMoveEvent pointerMoveEvent) {
        setState(() {
          _path[_path.length - 1].add(pointerMoveEvent.localPosition);
        });
      },
      onPointerUp: (PointerUpEvent pointerUpEvent) {
        setState(() {
          _path[_path.length - 1].add(pointerUpEvent.localPosition);
        });
      },
      onPointerCancel: (PointerCancelEvent pointerCancelEvent) {
        setState(() {
          _path[_path.length - 1].add(pointerCancelEvent.localPosition);
        });
      },
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: GestureDetector(
          onTapDown: (details) {
            RenderBox box = context.findRenderObject() as RenderBox;
            final offset = box.globalToLocal(details.globalPosition);
            print('offset====$offset');
            for (var e in _path) {
              print('for===$e');
            }

            final index = _path.lastIndexWhere((rect) => rect.contains(offset));
            if (index != -1) {
              print(index);
              // onSelected(index);
              return;
            }
            // onSelected(-1);
          },
          child: CustomPaint(
            painter: DrawingBoardPainter(_path, context),
          ),
        ),
      ),
    );
  }
}
