import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:presentation/models/slide.dart';
import 'package:presentation/models/slide_factors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:watcher/watcher.dart';
import 'package:presentation/utils/color_utils.dart' as color_utils;

FlutterSlidesModel loadedSlides = FlutterSlidesModel();

class FlutterSlidesModel extends Model {
  List<Slide>? slides;
  late String externalFilesRoot;
  double slideWidth = 1920.0;
  double slideHeight = 1080.0;
  double fontScaleFactor = 1920.0;
  Color projectBGColor = const Color(0xFFF0F0F0);
  Color slidesListBGColor = const Color(0xFFDDDDDD);
  Color slidesListHighlightColor = const Color(0xFF40C4FF);
  bool animateSlideTransitions = false;
  bool showDebugContainers = false;
  bool autoAdvance = false;
  int autoAdvanceDurationMillis = 30000;

  StreamSubscription? _slidesFileSubscription;
  StreamSubscription? _replaceFileSubscription;

  void loadSlidesData(String filePath) async {
    _slidesFileSubscription?.cancel();
    _replaceFileSubscription?.cancel();
    _slidesFileSubscription = Watcher(filePath).events.listen((event) {
      loadSlidesData(filePath);
      notifyListeners();
    });
    // try {
    String fileString = File(filePath).readAsStringSync();
    const replaceFilePath = 'assets/example_presentation/replace_values.json';
    // final replaceFile = File(replaceFilePath);
    // if (replaceFile.existsSync()) {
    String replaceFileString = await rootBundle.loadString(replaceFilePath);
    Map replaceJSON = jsonDecode(replaceFileString);
    for (final entry in replaceJSON.entries) {
      fileString = fileString.replaceAll(
          "\"@replace/${entry.key}\"", entry.value.toString());
    }
    _replaceFileSubscription = Watcher(replaceFilePath).events.listen((event) {
      loadSlidesData(filePath);
      notifyListeners();
    });
    // }
    Map json = jsonDecode(fileString);
    loadedSlides.slideWidth = (json['slide_width'] ?? 2880.0).toDouble();
    loadedSlides.slideHeight = (json['slide_height'] ?? 1800.0).toDouble();
    loadedSlides.fontScaleFactor =
        (json['font_scale_factor'] ?? loadedSlides.slideWidth).toDouble();
    loadedSlides.projectBGColor = color_utils
        .colorFromString(json['project_bg_color'], errorColor: Colors.red);
    loadedSlides.slidesListBGColor = color_utils.colorFromString(
        json['project_slide_list_bg_color'],
        errorColor: Colors.red);
    loadedSlides.slidesListHighlightColor = color_utils.colorFromString(
        json['project_slide_list_highlight_color'],
        errorColor: Colors.red);
    loadedSlides.animateSlideTransitions =
        json['animate_slide_transitions'] ?? false;
    loadedSlides.showDebugContainers = json['show_debug_containers'] ?? false;
    loadedSlides.externalFilesRoot = json['external_files_root'] ??
        File(filePath).parent.path + '/external_files';
    loadedSlides.autoAdvance = json['auto_advance'] ?? false;
    loadedSlides.autoAdvanceDurationMillis =
        json['auto_advance_duration_millis'] ?? 30000;

    imageCache?.maximumSize;
    SlideFactors slideFactors = SlideFactors(
      normalizationWidth: loadedSlides.slideWidth,
      normalizationHeight: loadedSlides.slideHeight,
      fontScaleFactor: loadedSlides.fontScaleFactor,
    );
    List slides = json['slides'];
    List<Slide> slideList = [];
    for (Map slide in slides) {
      List contentList = slide['content'];
      int advancementCount = slide['advancement_count'] ?? 0;
      bool animatedTransition = slide['animated_transition'] ?? false;
      Color slideBGColor = color_utils.colorFromString(
          slide['bg_color'] ?? '0xFFFFFFFF',
          errorColor: Colors.red);
      slideList.add(
        Slide(
            content: contentList,
            slideFactors: slideFactors,
            advancementCount: advancementCount,
            backgroundColor: slideBGColor,
            animatedTransition: animatedTransition),
      );
    }
    loadedSlides.slides = slideList;
    loadedSlides.notifyListeners();
    const MethodChannel('FlutterSlides:CustomPlugin', JSONMethodCodec())
        .invokeMethod('set', filePath);
    // } catch (e) {
    //   log("Error loading slides file: $e");
    // }
  }
}
