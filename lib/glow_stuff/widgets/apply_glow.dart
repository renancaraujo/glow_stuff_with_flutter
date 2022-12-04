import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:glow_stuff_with_flutter/glow_stuff/glow_stuff.dart';

class ApplyGlow extends StatefulWidget {
  const ApplyGlow({
    super.key,
    required this.child,
    this.density = 0.6,
    this.lightStrength = 1,
    this.weight = 0.09,
  });

  final Widget child;

  final double density;
  final double lightStrength;
  final double weight;

  @override
  State<ApplyGlow> createState() => _ApplyGlowState();
}

class _ApplyGlowState extends State<ApplyGlow> {
  @override
  void initState() {
    super.initState();
    getNoise();
  }

  ui.Image? noise;

  Future<void> getNoise() async {
    const assetImage = AssetImage('assets/noise.png');
    final key = await assetImage.obtainKey(ImageConfiguration.empty);

    assetImage
        .loadBuffer(
      key,
      PaintingBinding.instance.instantiateImageCodecFromBuffer,
    )
        .addListener(
      ImageStreamListener((image, synchronousCall) {
        setState(() {
          noise = image.image;
        });
      }),
    );
  }

  late final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

  @override
  Widget build(BuildContext context) {
    final noise = this.noise;
    if (noise == null) {
      return const SizedBox.shrink();
    }

    final horzDev = HorizontalDeviationProvider.of(context);

    return ScrollAwareBuilder(
      builder: (context, scrollFraction) {
        return ShaderBuilder(
          assetKey: 'shaders/dir_glow.glsl',
          child: widget.child,
          (context, shader, child) {
            return AnimatedSampler(
              child: child!,
              (ui.Image image, Size size, Offset offset, Canvas canvas) {
                final devicePixelRatio = this.devicePixelRatio;
                shader
                  ..setFloat(0, image.width.toDouble() / devicePixelRatio)
                  ..setFloat(1, image.height.toDouble() / devicePixelRatio)
                  ..setFloat(2, horzDev)
                  ..setFloat(3, scrollFraction)
                  ..setFloat(4, widget.density)
                  ..setFloat(5, widget.lightStrength)
                  ..setFloat(6, widget.weight)
                  ..setImageSampler(0, image)
                  ..setImageSampler(1, noise);
                canvas
                  ..save()
                  ..translate(offset.dx, offset.dy)
                  ..drawRect(
                    Offset.zero & size,
                    Paint()..shader = shader,
                  )
                  ..restore();
              },
            );
          },
        );
      },
    );
  }
}
