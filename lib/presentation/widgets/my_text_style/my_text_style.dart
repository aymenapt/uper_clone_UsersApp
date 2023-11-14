import 'package:flutter/material.dart';

import '../../app_manager/color_manager/color_manager.dart';

Widget MyDefaultTextStyle({
  required String text,
  Color color = white,
  required double height,
  bool bold = false,
}) {
  return Text(
    text,
    style: TextStyle(
        color: color,
        fontSize: height,
        fontFamily: 'Cairo',
        fontWeight: bold ? FontWeight.bold : FontWeight.normal),
    overflow: TextOverflow.ellipsis,
  );
}
