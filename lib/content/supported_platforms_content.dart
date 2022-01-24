import 'dart:async';

import 'package:presentation/models/normalization_multipliers.dart';
import 'package:flutter/material.dart';
import 'dart:ui' show lerpDouble;
import 'package:presentation/utils/curve_utils.dart' as curve_utils;
import 'package:presentation/utils/color_utils.dart' as color_utils;

class SupportedPlatformsContent extends StatefulWidget {
  final int defaultPage;
  final int initChangeDuration;
  final int pageChangeDuration;
  final int pageChangeAnimationDuration;
  final Curve pageChangeCurve;
  final double titleFontSizeMin;
  final double titleFontSizeMax;
  final double imageHeightMin;
  final double imageHeightMax;
  final double containerHeightMin;
  final double containerHeightMax;
  final Color titleFontColor;
  final List<dynamic> cellData;
  final bool debugColors;
  final double viewportFraction;
  final double titleTopPadding;
  final NormalizationMultipliers normMultis;

  SupportedPlatformsContent({
    required Map contentMap,
    required this.normMultis,
    Key? key,
  })  : defaultPage = contentMap['default_page'] ?? 1,
        pageChangeDuration = contentMap['page_change_duration_millis'] ?? 1500,
        initChangeDuration = contentMap['init_change_duration_millis'] ?? 1500,
        pageChangeAnimationDuration =
            contentMap['page_change_animation_duration_millis'] ?? 800,
        pageChangeCurve =
            curve_utils.curveFromString(contentMap['page_change_curve'] ?? ''),
        imageHeightMin = contentMap['image_height_min'],
        imageHeightMax = contentMap['image_height_max'],
        containerHeightMin = contentMap['container_height_min'],
        containerHeightMax = contentMap['container_height_max'],
        titleFontSizeMin = contentMap['title_font_size_min'],
        titleFontSizeMax = contentMap['title_font_size_max'],
        viewportFraction = contentMap['viewport_fraction'],
        debugColors = contentMap['debug_colors'] ?? false,
        titleTopPadding = contentMap['title_top_padding'],
        titleFontColor = color_utils.colorFromString(
          contentMap['title_font_color'],
          errorColor: const Color(0xFF52575B),
        ),
        cellData = contentMap['cell_data'],
        super(key: key);
  @override
  _SupportedPlatformsContentState createState() =>
      _SupportedPlatformsContentState();
}

class _SupportedPlatformsContentState extends State<SupportedPlatformsContent> {
  late PageController _pageController;
  Timer? _pageChangeTimer;
  late int _currPage;
  @override
  void initState() {
    super.initState();
    _currPage = widget.defaultPage;
    _pageController = PageController(
        initialPage: _currPage, viewportFraction: widget.viewportFraction);

    Future.delayed(Duration(milliseconds: widget.initChangeDuration), () {
      _currPage++;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currPage,
          duration: Duration(milliseconds: widget.pageChangeAnimationDuration),
          curve: widget.pageChangeCurve,
        );
      }
      if (mounted) {
        _pageChangeTimer = Timer.periodic(
          Duration(milliseconds: widget.pageChangeDuration),
          (timer) {
            if (mounted) {
              _currPage++;
              _pageController.animateToPage(
                _currPage,
                duration:
                    Duration(milliseconds: widget.pageChangeAnimationDuration),
                curve: widget.pageChangeCurve,
              );
            }
          },
        );
      }
    });
  }

  @override
  void dispose() {
    _pageChangeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          color:
              Colors.yellowAccent.withOpacity(widget.debugColors ? 0.25 : 0.0),
          child: PageView.builder(
            controller: _pageController,
            itemCount: 100000,
            itemBuilder: (context, index) {
              return Center(
                child: AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double currPage;
                    try {
                      currPage = _pageController.page ?? 1;
                    } catch (e) {
                      currPage = widget.defaultPage.toDouble();
                    }
                    double scale = 1.0;
                    double fontSize = widget.titleFontSizeMin;
                    double containerHeight = widget.containerHeightMin;
                    double imageHeight = widget.imageHeightMin;
                    if ((index.toDouble() - currPage).abs() < 2.0) {
                      scale = (2.0 - (index.toDouble() - currPage).abs());
                      if (scale > 1.0) {
                        fontSize = lerpDouble(widget.titleFontSizeMin,
                                widget.titleFontSizeMax, (1.0 - scale).abs()) ??
                            0.0;
                        containerHeight = lerpDouble(
                                containerHeight,
                                widget.containerHeightMax,
                                (1.0 - scale).abs()) ??
                            0.0;
                        imageHeight = lerpDouble(imageHeight,
                                widget.imageHeightMax, (1.0 - scale).abs()) ??
                            0.0;
                      }
                    }
                    return Stack(
//                    fit: StackFit.expand,
                      alignment: Alignment.center,
                      children: <Widget>[
                        ConstrainedBox(
                          constraints: BoxConstraints.tightForFinite(
                            height: containerHeight * widget.normMultis.height,
                          ),
                          child: Container(
                            color: Colors.red
                                .withOpacity(widget.debugColors ? 0.25 : 0.0),
                            child: Column(
                              children: <Widget>[
                                Expanded(
                                  child: Container(),
                                ),
                                SizedBox(
                                  height:
                                      imageHeight * widget.normMultis.height,
                                  child: Image.asset(
                                    "assets/example_presentation/external_files/" +
                                        widget.cellData[index %
                                            widget.cellData.length]['filepath'],
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                Container(
                                    height: widget.titleTopPadding *
                                        widget.normMultis.height),
                                Text(
                                  widget.cellData[
                                      index % widget.cellData.length]['title'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: widget.titleFontColor,
                                    fontSize: fontSize * widget.normMultis.font,
                                  ),
                                ),
                                Expanded(
                                  child: Container(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
        Positioned.fill(
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xFFFFFFFF), Color(0x00FFFFFF)],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [Color(0xFFFFFFFF), Color(0x00FFFFFF)],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
