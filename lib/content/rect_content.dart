import 'package:flutter/material.dart';
import 'package:presentation/utils/color_utils.dart' as color_utils;

class RectContent extends StatelessWidget {
  final Color fillColor;
  RectContent({Key? key, required Map contentMap})
      : fillColor = color_utils.colorFromString(contentMap['fill'],
            errorColor: Colors.red),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(color: fillColor);
  }
}
