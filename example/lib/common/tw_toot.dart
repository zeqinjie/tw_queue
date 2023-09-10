import 'dart:math';

import 'package:flutter/material.dart';

class TWTool {
  /// 随机颜色
  static Color randomColor() {
    return Color.fromARGB(255, Random().nextInt(256) + 0,
        Random().nextInt(256) + 0, Random().nextInt(256) + 0);
  }
}
