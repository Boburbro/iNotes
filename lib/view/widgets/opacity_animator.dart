import 'package:flutter/material.dart';

/// Custom widget that can make any widget animated as opacity.
class OpacityAnimator extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final double beginingOpacity;

  const OpacityAnimator({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 1),
    this.beginingOpacity = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      key: const Key('opacity.animator'),
      tween: Tween<double>(begin: beginingOpacity, end: 1),
      duration: duration,
      child: child,
      builder: (context, double v, Widget? c) => Opacity(opacity: v, child: c),
    );
  }
}
