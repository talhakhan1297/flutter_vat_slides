import 'dart:io';
import 'dart:typed_data';

import 'package:presentation/models/slides.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart' show rootBundle;

class LottieContent extends StatefulWidget {
  final String? compositionAssetPath;
  final String compositionFilePath;

  LottieContent({
    Key? key,
    required Map contentMap,
  })  : compositionAssetPath = contentMap['asset'],
        compositionFilePath = contentMap['file'],
        super(key: key);
  @override
  _LottieContentState createState() => _LottieContentState();
}

class _LottieContentState extends State<LottieContent>
    with SingleTickerProviderStateMixin {
  LottieComposition? _composition;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1),
      vsync: this,
    );
    _controller.addListener(() {});
    loadLottieComposition().then((composition) {
      setState(() {
        _composition = composition;
        _controller.duration = _composition?.duration;
        _controller.repeat();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(LottieContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    loadLottieComposition().then((composition) {
      setState(() {
        _composition = composition;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      Size size;
      if (_composition == null) {
        return const SizedBox();
      }
      if (constraints.biggest.width <= 0.01 ||
          constraints.biggest.height <= 0.01) {
        size = Size.zero;
      } else if (_composition!.bounds.width >= _composition!.bounds.height) {
        // Stretch to largest width possible and aspect fit height
        double aspectRatioMultiplier =
            _composition!.bounds.height / _composition!.bounds.width;
        double width = constraints.biggest.width;
        double height = width * aspectRatioMultiplier;
        size = Size(width, height);
        if (height > constraints.biggest.height) {
          double aspectRatioMultiplier =
              _composition!.bounds.width / _composition!.bounds.height;
          double height = constraints.biggest.height;
          double width = height * aspectRatioMultiplier;
          size = Size(width, height);
        }
      } else {
        // Stretch to largest height possible and aspect fit width
        double aspectRatioMultiplier =
            _composition!.bounds.width / _composition!.bounds.height;
        double height = constraints.biggest.height;
        double width = height * aspectRatioMultiplier;
        size = Size(width, height);
        if (width > constraints.biggest.width) {
          double aspectRatioMultiplier =
              _composition!.bounds.height / _composition!.bounds.width;
          double width = constraints.biggest.width;
          double height = width * aspectRatioMultiplier;
          size = Size(width, height);
        }
      }
      return Center(
        child: Lottie(
          width: size.width,
          height: size.height,
          composition: _composition,
          controller: _controller,
        ),
      );
    });
  }

  Future<LottieComposition> loadLottieComposition() async {
    if (widget.compositionAssetPath != null) {
      return await loadAsset(widget.compositionAssetPath!);
    } else {
      return await loadFile(widget.compositionFilePath);
    }
  }

  Future<LottieComposition> loadAsset(String assetName) async {
    return await rootBundle
        .loadString(assetName)
        .then<Uint8List>((String data) => Uint8List.fromList(data.codeUnits))
        .then((Uint8List map) => LottieComposition.fromBytes(map));
  }

  Future<LottieComposition> loadFile(String filePath) async {
    var assetData = await rootBundle
        .load('assets/example_presentation/external_files/$filePath');
    return await LottieComposition.fromByteData(assetData);
    // return await File('${loadedSlides.externalFilesRoot}/$filePath')
    //     .readAsString()
    //     .then<Uint8List>((String data) => Uint8List.fromList(data.codeUnits))
    //     .then((Uint8List map) => LottieComposition.fromBytes(map));
  }
}
