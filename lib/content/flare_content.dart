import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
// import 'package:nima/nima_actor.dart';

class FlareActorContent extends StatelessWidget {
  final String assetPath;
  final String animationName;

  FlareActorContent({Key? key, required Map contentMap})
      : assetPath = contentMap['asset'],
        animationName = contentMap['animation_name'],
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlareActor(
      assetPath,
      alignment: Alignment.center,
      fit: BoxFit.contain,
      animation: animationName,
    );
  }
}

// class NimaActorContent extends StatelessWidget {
//   final String assetPath;
//   final String animationName;

//   NimaActorContent({Key? key, required Map contentMap})
//       : assetPath = contentMap['asset'],
//         animationName = contentMap['animation_name'],
//         super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return NimaActor(
//       assetPath,
//       alignment: Alignment.center,
//       fit: BoxFit.contain,
//       animation: animationName,
//     );
//   }
// }
