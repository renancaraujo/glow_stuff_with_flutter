import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sensors_plus/sensors_plus.dart';

class HorizontalDeviationProvider extends StatefulWidget {
  const HorizontalDeviationProvider({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<HorizontalDeviationProvider> createState() =>
      _HorizontalDeviationProviderState();

  static double of(BuildContext context) {
    final result =
        context.dependOnInheritedWidgetOfExactType<_HorzDevInherit>();
    assert(result != null, 'No _HorzDevInherit found in context');
    return result!.position;
  }
}

class _HorizontalDeviationProviderState
    extends State<HorizontalDeviationProvider> {
  Size biggest = const Size(1, 1);

  double position = 0.5;

  void handlePointerHover(PointerHoverEvent event) {
    final frac = 2 * (event.localPosition.dx / biggest.width) - 1;
    final sign = frac.sign;
    final quad = frac * frac * sign;

    setState(() {
      position = (quad + 1) / 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constrainst) {
        biggest = constrainst.biggest;
        return Listener(
          onPointerHover: handlePointerHover,
          child: GyroRoll(
            rotationX: position,
            builder: (context, value) {
              return TweenAnimationBuilder(
                duration: const Duration(milliseconds: 350),
                tween: Tween<double>(begin: 0, end: value),
                builder: (context, value, child) {
                  return _HorzDevInherit(
                    position: value,
                    child: widget.child,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _HorzDevInherit extends InheritedWidget {
  const _HorzDevInherit({
    required super.child,
    required this.position,
  });

  final double position;

  @override
  bool updateShouldNotify(_HorzDevInherit old) {
    return true;
  }
}

class GyroRoll extends StatefulWidget {
  const GyroRoll({
    super.key,
    required this.rotationX,
    required this.builder,
  });

  final double rotationX;

  final Widget Function(BuildContext context, double deviation) builder;

  @override
  State<GyroRoll> createState() => _GyroRollState();
}

class _GyroRollState extends State<GyroRoll> {
  StreamSubscription<GyroscopeEvent>? subscription;

  @override
  void initState() {
    super.initState();

    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      subscription = gyroscopeEvents.listen(handleGyro);
    }
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  late double rotationX = widget.rotationX;
  bool renderLock = false;

  @override
  void didUpdateWidget(covariant GyroRoll oldWidget) {
    super.didUpdateWidget(oldWidget);

    rotationX = widget.rotationX;

    renderLock = true;
    Future.delayed(const Duration(milliseconds: 500), () {
      renderLock = false;
    });
  }

  void handleGyro(GyroscopeEvent event) {
    if (renderLock) return;
    renderLock = true;

    final amount =
        defaultTargetPlatform == TargetPlatform.iOS ? event.x : event.y;
    final factor = defaultTargetPlatform == TargetPlatform.iOS ? 1500 : 750;

    setState(() {
      rotationX += (amount * 100).toInt() / factor;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      renderLock = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, rotationX);
  }
}
