import 'package:flutter/material.dart';

/// Provides smooth, Apple-inspired route transitions for the app.
class RouteTransitions {
  /// Creates a fade transition with subtle scale for Apple-like feel
  static PageRoute<T> fadeRoute<T>({
    required Widget Function(BuildContext, Animation<double>, Animation<double>) builder,
    required T Function() createPage,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return _FadePageRoute<T>(
      builder: builder,
      createPage: createPage,
      duration: duration,
    );
  }

  /// Creates a slide-up transition (material-style)
  static PageRoute<T> slideUpRoute<T>({
    required Widget Function(BuildContext, Animation<double>, Animation<double>) builder,
    required T Function() createPage,
    Duration duration = const Duration(milliseconds: 350),
  }) {
    return _SlideUpPageRoute<T>(
      builder: builder,
      createPage: createPage,
      duration: duration,
    );
  }
}

class _FadePageRoute<T> extends PageRoute<T> {
  _FadePageRoute({
    required this.builder,
    required this.createPage,
    this.duration = const Duration(milliseconds: 300),
  });

  final Widget Function(BuildContext, Animation<double>, Animation<double>) builder;
  final T Function() createPage;
  final Duration duration;

  @override
  bool get barrierDismissible => false;

  @override
  Color? get barrierColor => null;

  @override
  String get barrierLabel => '';

  @override
  bool get maintainState => true;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context, animation, secondaryAnimation);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic),
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.95, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic),
        ),
        child: child,
      ),
    );
  }
}

class _SlideUpPageRoute<T> extends PageRoute<T> {
  _SlideUpPageRoute({
    required this.builder,
    required this.createPage,
    this.duration = const Duration(milliseconds: 350),
  });

  final Widget Function(BuildContext, Animation<double>, Animation<double>) builder;
  final T Function() createPage;
  final Duration duration;

  @override
  bool get barrierDismissible => false;

  @override
  Color? get barrierColor => null;

  @override
  String get barrierLabel => '';

  @override
  bool get maintainState => true;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context, animation, secondaryAnimation);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic),
      ),
      child: FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic),
        child: child,
      ),
    );
  }
}
