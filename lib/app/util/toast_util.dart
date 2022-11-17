import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

/// @author Kevin
/// @date 2022/11/11 17:18
/// @desc
class Toast {
  static show(String msg) {
    showToast(
      "$msg",
      position: ToastPosition.center,
      backgroundColor: Colors.black.withOpacity(0.6),
      radius: 5.0,
      textStyle: TextStyle(fontSize: 14.0),
    );
  }
}
