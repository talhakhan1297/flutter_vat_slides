import 'package:flutter/material.dart';
import 'package:presentation/utils/color_utils.dart' as color_utils;
import 'package:presentation/utils/align_utils.dart' as align_utils;

class LabelContent extends StatelessWidget {
  final String text;
  final Alignment alignment;
  final TextStyle textStyle;
  final TextAlign textAlign;
  const LabelContent({
    Key? key,
    required this.text,
    required this.textStyle,
    required this.textAlign,
    required this.alignment,
  }) : super(key: key);

  factory LabelContent.fromContentMap({
    required Map contentMap,
    required double fontScaleFactor,
  }) {
    String text = contentMap['text'];
    Color fontColor = color_utils.colorFromString(contentMap['font_color'],
        errorColor: Colors.red);
    double fontSize = (contentMap['font_size'] as num).toDouble();
    double? lineHeight = (contentMap['line_height'] as num?)?.toDouble();
    double? letterSpacing = (contentMap['letter_spacing'] as num?)?.toDouble();
    String? textAlignStr = contentMap['text_align'];
    String? fontFamily = contentMap['font_family'];
    bool strikeThrough = contentMap['strike_through'] ?? false;
    bool italic = contentMap['italic'] ?? false;
    TextStyle textStyle = TextStyle(
        color: fontColor,
        fontSize: (fontSize * fontScaleFactor).toDouble(),
        height: 1.0);
    textStyle = textStyle.copyWith(fontFamily: fontFamily);
    textStyle = textStyle.copyWith(height: lineHeight);
    if (strikeThrough == true) {
      textStyle = textStyle.copyWith(decoration: TextDecoration.lineThrough);
    }
    if (italic) {
      textStyle = textStyle.copyWith(fontStyle: FontStyle.italic);
    }
    letterSpacing = (letterSpacing ?? 1.0) * fontScaleFactor;
    textStyle = textStyle.copyWith(letterSpacing: letterSpacing);
    TextAlign textAlign = TextAlign.start;
    if (textAlignStr == 'center') {
      textAlign = TextAlign.center;
    } else if (textAlignStr == 'end') {
      textAlign = TextAlign.end;
    } else if (textAlignStr == 'start') {
      textAlign = TextAlign.start;
    } else {
      textAlign = TextAlign.center;
    }
    final alignment =
        align_utils.alignmentFromString(contentMap['align'] ?? "");
    return LabelContent(
      text: text,
      textStyle: textStyle,
      textAlign: textAlign,
      alignment: alignment,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Text(text, style: textStyle, textAlign: textAlign),
    );
  }
}
