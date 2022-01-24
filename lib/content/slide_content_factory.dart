import 'package:presentation/content/desktop_embedding_content.dart';
import 'package:presentation/content/error_content.dart';
import 'package:presentation/content/flare_content.dart';
import 'package:presentation/content/image_content.dart';
import 'package:presentation/content/label_content.dart';
import 'package:presentation/content/lottie_content.dart';
import 'package:presentation/content/main_title_content.dart';
import 'package:presentation/content/rect_content.dart';
import 'package:presentation/content/supported_platforms_content.dart';
import 'package:presentation/content/team_photos_content.dart';
import 'package:presentation/models/normalization_multipliers.dart';
import 'package:presentation/content/pillars_content.dart';
import 'package:presentation/content/coding_rolodex_content.dart';
import 'package:flutter/material.dart';

typedef Constructor<Widget> = Widget Function(
  SlideContentParams contentParams,
);

class SlideContentParams {
  final Map contentMap;
  final bool isPreview;
  final NormalizationMultipliers normalizationMultipliers;
  final ValueNotifier<int> slideAdvancementNotifier;

  SlideContentParams({
    required this.contentMap,
    required this.isPreview,
    required this.normalizationMultipliers,
    required this.slideAdvancementNotifier,
  });
}

class SlideContentFactory {
  static final SlideContentFactory _contentFactory =
      SlideContentFactory._internal();

  factory SlideContentFactory() => _contentFactory;

  SlideContentFactory._internal() {
    register('error', (params) => const ErrorContent());
    register('rect', (params) => RectContent(contentMap: params.contentMap));
    register(
      'label',
      (params) => LabelContent.fromContentMap(
        contentMap: params.contentMap,
        fontScaleFactor: params.normalizationMultipliers.font,
      ),
    );
    register('image', (params) => ImageContent(contentMap: params.contentMap));
    register('lottie_animation',
        (params) => LottieContent(contentMap: params.contentMap));
    // register('nima_actor',
    //     (params) => NimaActorContent(contentMap: params.contentMap));
    register('flare_actor',
        (params) => FlareActorContent(contentMap: params.contentMap));
    register(
        'desktop_embedding',
        (params) => DesktopEmbeddingContent(
            normalizationMultipliers: params.normalizationMultipliers));
    register(
        'coding_rolodex_screen',
        (params) => CodingRolodexContent(
            shouldAnimate: !params.isPreview,
            normMultis: params.normalizationMultipliers));
    register(
      'main_title_slide',
      (params) => MainTitleContent(
        title: '',
        contentMap: params.contentMap,
        shouldAnimate: !params.isPreview,
        normMultis: params.normalizationMultipliers,
      ),
    );
    register(
        'team_photos',
        (params) => TeamPhotosContent(
            contentMap: params.contentMap, isPreview: params.isPreview));
    register(
        'supported_platforms',
        (params) => SupportedPlatformsContent(
            contentMap: params.contentMap,
            normMultis: params.normalizationMultipliers));
    register(
        'flutter_pillars',
        (params) => PillarsContent(
            contentMap: params.contentMap,
            normMultis: params.normalizationMultipliers,
            advancementStep: params.slideAdvancementNotifier));
  }

  final _constructors = <String, Constructor<Widget>>{};
  void register(String type, Constructor constructor) {
    _constructors[type] = constructor as Widget Function(SlideContentParams);
  }

  Widget generate(
    String type,
    Map contentMap,
    bool isPreview,
    NormalizationMultipliers normalizationMultipliers,
    ValueNotifier<int> slideAdvancementNotifier,
  ) {
    return (_constructors[type] ?? _constructors['error'])!(
      SlideContentParams(
        contentMap: contentMap,
        isPreview: isPreview,
        normalizationMultipliers: normalizationMultipliers,
        slideAdvancementNotifier: slideAdvancementNotifier,
      ),
    );
  }
}
