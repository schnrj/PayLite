import 'package:flutter/material.dart';

/// Motion utility honoring system accessibility reduce-motion settings
class AppMotion {
  static bool shouldReduceMotion(BuildContext context) {
    return MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  }

  static Duration duration(BuildContext context, {int normalMs = 300}) {
    return shouldReduceMotion(context) ? Duration.zero : Duration(milliseconds: normalMs);
  }

  static Widget animatedFadeSlide({
    required BuildContext context,
    required Widget child,
    Offset offset = const Offset(0, 0.05),
    Duration duration = const Duration(milliseconds: 350),
    Curve curve = Curves.easeOutCubic,
  }) {
    if (shouldReduceMotion(context)) {
      return child;
    }
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(offset.dx * (1 - value) * 100, offset.dy * (1 - value) * 100),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
