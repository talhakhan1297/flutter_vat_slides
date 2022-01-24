import 'dart:async';
import 'package:presentation/models/slides.dart';
import 'package:presentation/slides/slide_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:file_picker/file_picker.dart' as file_chooser;

class SlidePresentation extends StatefulWidget {
  const SlidePresentation({Key? key}) : super(key: key);

  @override
  _SlidePresentationState createState() => _SlidePresentationState();
}

class _SlidePresentationState extends State<SlidePresentation>
    with TickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  int _currentSlideIndex = 0;
  int _transitionStartIndex = 0;
  int _transitionEndIndex = 0;
  final int _lisTapKeycode = 6;
  bool listTapAllowed = false;
  late AnimationController _transitionController;
  late AnimationController _slideListController;
  double _lastSlideListScrollOffset = 0.0;
  final SlidePageController _slidePageController = SlidePageController();
  Timer? _autoAdvanceTimer;

  @override
  void initState() {
    super.initState();

    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideListController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    const MethodChannel('FlutterSlides:CustomPlugin', JSONMethodCodec())
        .invokeMethod('get')
        .then((result) {
      if (result != null) {
        FlutterSlidesModel().loadSlidesData(result);
        // FlutterSlidesModel()
        //     .loadSlidesData("assets/example_presentation/flutter_live.json");
      }
    });
  }

  @override
  void dispose() {
    _slideListController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    FocusScope.of(context).requestFocus(_focusNode);
  }

  @override
  Widget build(BuildContext context) {
    FlutterSlidesModel model =
        ScopedModel.of<FlutterSlidesModel>(context, rebuildOnChange: true);

    _autoAdvanceTimer?.cancel();
    if (model.autoAdvance) {
      _autoAdvanceTimer = Timer.periodic(
          Duration(milliseconds: model.autoAdvanceDurationMillis), (_) {
        _advancePresentation(model);
      });
    }

    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: (event) {
        onKeyEvent(event, model);
      },
      child: AnimatedBuilder(
        animation: _slideListController,
        builder: (context, child) {
          // ignore: unnecessary_null_comparison
          if (model.slides == null) {
            return _emptyState(
              model.projectBGColor,
              model.slidesListHighlightColor,
            );
          }
          bool animatedTransition =
              model.slides?[_currentSlideIndex].animatedTransition ??
                  false || model.animateSlideTransitions;
          return Container(
              color: model.projectBGColor,
              constraints: const BoxConstraints.expand(),
              child: Stack(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(width: _slideListController.value * 200.0),
                      Container(width: _slideListController.value * 50.0),
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child: animatedTransition
                              ? _animatedSlideTransition(model)
                              : _currentSlide(model),
                        ),
                      ),
                      Container(width: _slideListController.value * 50.0),
                    ],
                  ),
                  _slideListController.value <= 0.01
                      ? Container()
                      : _slideList(model),
                ],
              ));
        },
      ),
    );
  }

  _animatedSlideTransition(FlutterSlidesModel model) {
    final startingSlide = SlidePage(
      slide: model.slides![_transitionStartIndex],
    );
    final endingSlide = SlidePage(
      key: GlobalObjectKey(model.slides?[_transitionEndIndex] ?? 0),
      slide: model.slides![_transitionEndIndex],
      controller: _slidePageController,
    );
    return FlutterSlidesTransition(
      animation: _transitionController,
      startingSlide: startingSlide,
      endingSlide: endingSlide,
      transitionBuilder: (context, start, end) {
        final firstScreen = Opacity(
          opacity: 1.0 - _transitionController.value,
          child: start,
        );
        final secondScreen = Opacity(
          opacity: _transitionController.value,
          child: end,
        );
        final stackLayout = Stack(
          children: <Widget>[
            firstScreen,
            secondScreen,
          ],
        );
        return stackLayout;
      },
    );
  }

  Widget _currentSlide(FlutterSlidesModel model) {
    return SlidePage(
      slide: model.slides![_currentSlideIndex],
      controller: _slidePageController,
      index: _currentSlideIndex,
    );
  }

  Widget _slideList(FlutterSlidesModel model) {
    return Transform.translate(
      offset: Offset(-200.0 + _slideListController.value * 200.0, 0.0),
      child: Container(
        width: 200.0,
        color: model.slidesListBGColor,
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            _lastSlideListScrollOffset = notification.metrics.pixels;
            return true;
          },
          child: ListView.builder(
            controller: ScrollController(
              initialScrollOffset: _lastSlideListScrollOffset,
            ),
            itemCount: model.slides?.length ?? 0,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTapDown: (details) {
                  if (listTapAllowed) {
                    setState(() {
                      _moveToSlideAtIndex(model, index);
                    });
                  }
                },
                child: Stack(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _currentSlideIndex != index
                              ? Colors.transparent
                              : model.slidesListHighlightColor,
                          width: 4.0,
                        ),
                      ),
                      child: SlidePage(
                        isPreview: true,
                        slide: model.slides![index],
                      ),
                    ),
                    Positioned(
                      bottom: 6.0,
                      left: 6.0,
                      child: SizedBox(
                        height: 20.0,
                        child: Material(
                          color:
                              model.slidesListHighlightColor.withOpacity(0.75),
                          child: Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Text(
                                '$index',
                                style: const TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.white,
                                    fontFamily: "RobotoMono"),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _emptyState(Color bgColor, Color buttonColor) {
    return Material(
      color: bgColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            const Text(
              "Flutter Slides",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 32.0),
            ),
            Container(
              height: 12.0,
            ),
            MaterialButton(
              minWidth: 200.0,
              height: 60.0,
              color: buttonColor,
              onPressed: () async {
                final file = await file_chooser.FilePicker.platform.pickFiles();
                if (file != null && file.files.first.path != null) {
                  FlutterSlidesModel().loadSlidesData(file.files.first.path!);
                }
                // file_chooser.showOpenPanel((result, paths) {
                // }, allowsMultipleSelection: false);
              },
              child: const Text(
                'Open',
                style: TextStyle(color: Colors.white, fontSize: 24.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  onKeyEvent(RawKeyEvent event, FlutterSlidesModel model) {
    switch (event.runtimeType) {
      case RawKeyDownEvent:
        break;
      case RawKeyUpEvent:
        int upKeyCode;
        switch (event.data.runtimeType) {
          case RawKeyEventDataMacOs:
            final RawKeyEventDataMacOs data =
                event.data as RawKeyEventDataMacOs;
            upKeyCode = data.keyCode;
            if (upKeyCode == _lisTapKeycode) {
              listTapAllowed = false;
            }
            break;
          default:
            throw Exception('Unsupported platform');
        }
        return;
      default:
        throw Exception('Unexpected runtimeType of RawKeyEvent');
    }

    int keyCode;
    switch (event.data.runtimeType) {
      case RawKeyEventDataMacOs:
        final RawKeyEventDataMacOs data = event.data as RawKeyEventDataMacOs;
        keyCode = data.keyCode;
        if (keyCode == 33) {
          _slideListController.reverse();
        } else if (keyCode == 49) {
          _advancePresentation(model);
        } else if (keyCode == 30) {
          _slideListController.forward();
        } else if (keyCode == 123) {
          // tapped left
          _reversePresentation(model);
        } else if (keyCode == 124) {
          _advancePresentation(model);
        } else if (keyCode == _lisTapKeycode) {
          listTapAllowed = true;
        }
        break;
      default:
        throw Exception('Unsupported platform');
    }
  }

  void _advancePresentation(FlutterSlidesModel model) {
    bool didAdvanceSlideContent = _slidePageController.advanceSlideContent();
    if (!didAdvanceSlideContent) {
      if (model.autoAdvance &&
          _currentSlideIndex == (model.slides?.length ?? 0) - 1) {
        _moveToSlideAtIndex(model, 0);
      } else {
        _moveToSlideAtIndex(model, _currentSlideIndex + 1);
      }
    }
  }

  void _reversePresentation(FlutterSlidesModel model) {
    bool didReverseSlideContent = _slidePageController.reverseSlideContent();
    if (!didReverseSlideContent) {
      _moveToSlideAtIndex(model, _currentSlideIndex - 1);
    }
  }

  void _moveToSlideAtIndex(FlutterSlidesModel model, int index) {
    int nextIndex = index.clamp(0, (model.slides?.length ?? 0) - 1);
    int prepIndex = (index + 1).clamp(0, (model.slides?.length ?? 0) - 1);
    if (_currentSlideIndex == nextIndex) {
      return;
    }

    // precaching next slide images.
    if (prepIndex != nextIndex) {
      for (Map content in model.slides![prepIndex].content) {
        if (content['type'] == 'image') {
          if (content['evict'] ?? false) continue;
          late ImageProvider provider;
          if (content.containsKey('asset')) {
            provider = Image.asset(content['asset']).image;
          }
          if (content.containsKey('file')) {
            const root = "assets/example_presentation/external_files";
            provider = AssetImage('$root/${content['file']}');
          }
          final config = createLocalImageConfiguration(context);
          provider.resolve(config);
        }
      }
    }
    setState(() {
      _transitionController.forward(from: 0.0);
      _transitionStartIndex = _currentSlideIndex;
      _transitionEndIndex = nextIndex;
      _currentSlideIndex = nextIndex;
    });
  }
}

typedef FlutterSlidesTransitionBuilder = Widget Function(
    BuildContext context, SlidePage startingSlide, SlidePage endingSlide);

class FlutterSlidesTransition extends AnimatedWidget {
  final SlidePage startingSlide;
  final SlidePage endingSlide;
  final FlutterSlidesTransitionBuilder transitionBuilder;

  // ignore: use_key_in_widget_constructors
  const FlutterSlidesTransition({
    required this.startingSlide,
    required this.endingSlide,
    required this.transitionBuilder,
    required Listenable animation,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return transitionBuilder(context, startingSlide, endingSlide);
  }
}
