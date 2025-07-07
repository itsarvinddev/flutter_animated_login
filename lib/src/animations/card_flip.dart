// File: src/animations/card_flip.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/enums.dart';

/// A widget that animates its child using a 3D flip transition.
class CardFlipTransition extends StatefulWidget {
  /// The widget to be animated
  final Widget child;

  /// Direction of the flip animation
  final FlipDirection direction;

  /// Duration of the animation
  final Duration duration;

  /// Curve of the animation
  final Curve curve;

  const CardFlipTransition({
    super.key,
    required this.child,
    this.direction = FlipDirection.horizontal,
    this.duration = const Duration(milliseconds: 15000),
    this.curve = Curves.easeInOutBack,
  });

  @override
  State<CardFlipTransition> createState() => _CardFlipTransitionState();
}

class _CardFlipTransitionState extends State<CardFlipTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  Widget? _oldChild;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    _oldChild = widget.child;
    _controller.forward();
  }

  @override
  void didUpdateWidget(CardFlipTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.child.key != oldWidget.child.key) {
      _oldChild = oldWidget.child;
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final value = _animation.value;
        bool showFrontSide = value <= 0.5;

        // Normalize animation value for each half
        final t = showFrontSide ? value * 2 : (value - 0.5) * 2;

        // Compute rotation based on direction
        Offset rotationPoint;
        double angle;

        switch (widget.direction) {
          case FlipDirection.horizontal:
            rotationPoint = const Offset(0.5, 0.0);
            angle = showFrontSide ? math.pi * t : math.pi * (1 - t);
            break;

          case FlipDirection.horizontalReverse:
            rotationPoint = const Offset(0.5, 0.0);
            angle = showFrontSide ? -math.pi * t : -math.pi * (1 - t);
            break;

          case FlipDirection.vertical:
            rotationPoint = const Offset(0.0, 0.5);
            angle = showFrontSide ? math.pi * t : math.pi * (1 - t);
            break;

          case FlipDirection.verticalReverse:
            rotationPoint = const Offset(0.0, 0.5);
            angle = showFrontSide ? -math.pi * t : -math.pi * (1 - t);
            break;
        }

        return Transform(
          transform: _createMatrix4(
            rotationPoint,
            isHorizontal ? angle : 0.0,
            isHorizontal ? 0.0 : angle,
          ),
          alignment: Alignment.center,
          child: _animation.value <= 0.5 ? _oldChild : widget.child,
        );
      },
    );
  }

  // Helper to check if direction is horizontal
  bool get isHorizontal =>
      widget.direction == FlipDirection.horizontal ||
      widget.direction == FlipDirection.horizontalReverse;

  // Create 3D rotation matrix
  Matrix4 _createMatrix4(Offset rotationPoint, double angleX, double angleY) {
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.001) // perspective
      ..translate(
        rotationPoint.dx != 0.0 ? 0.0 : 0.0,
        rotationPoint.dy != 0.0 ? 0.0 : 0.0,
        0.0,
      );

    if (angleX != 0.0) {
      matrix.rotateY(angleX);
    }

    if (angleY != 0.0) {
      matrix.rotateX(angleY);
    }

    return matrix;
  }
}
