import 'package:presentation/models/slides.dart';
import 'package:presentation/slides/slide_presentation.dart';
// import 'package:flutter/foundation.dart'
//     show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

void main() {
  runApp(_MyApp());
}

class _MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<FlutterSlidesModel>(
      model: loadedSlides,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'GoogleSans',
        ),
        home: const SlidePresentation(),
      ),
    );
  }
}
