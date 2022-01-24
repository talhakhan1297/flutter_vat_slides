import 'package:flutter/material.dart';
import 'package:presentation/utils/image_utils.dart' as image_utils;
import 'package:url_launcher/url_launcher.dart';

class ImageContent extends StatelessWidget {
  final String? assetPath;
  final String? filePath;
  final BoxFit? fit;
  final bool evict;
  final String? url;

  ImageContent({Key? key, required Map contentMap})
      : assetPath = contentMap['asset'] as String?,
        filePath = contentMap['file'] as String?,
        url = contentMap['url'] as String?,
        fit = contentMap['fit'] == null
            ? BoxFit.contain
            : image_utils.boxFitFromString(contentMap['fit']),
        evict = contentMap['evict'] ?? false,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (assetPath != null) {
      if (evict) {
        Image.asset(assetPath!).image.evict();
      }
      final Image image = Image.asset(assetPath!, fit: fit);
      if (url != null) {
        return InkWell(
          onTap: () async {
            launch(url!);
          },
          child: image,
        );
      }
      return image;
    } else {
      const root = "assets/example_presentation/external_files";
      if (evict) {
        AssetImage('$root/$filePath').evict();
      }
      final Image image = Image.asset(
        '$root/$filePath',
        fit: fit,
      );
      if (url != null) {
        return InkWell(
          onTap: () async {
            await launch(url!);
          },
          child: image,
        );
      }
      return image;
    }
  }
}
