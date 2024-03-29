import 'package:flutter/material.dart';

enum TwTransitionType {
  inFromLeft,
  inFromRight,
  inFromTop,
  inFromBottom,
  scale,
  fade,
  rotation,
  size,
}

Future<T?> twShowAnimationDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  Duration? transitionDuration,
  Color? barrierColor,
  TwTransitionType transitionType = TwTransitionType.inFromLeft,
}) {
  assert(debugCheckHasMaterialLocalizations(context));

  final ThemeData theme = Theme.of(context);
  return showGeneralDialog(
    context: context,
    pageBuilder: (BuildContext buildContext, Animation<double> animation,
        Animation<double> secondaryAnimation) {
      final Widget pageChild = Builder(builder: builder);
      return SafeArea(
        child: Builder(builder: (BuildContext context) {
          return Theme(
            data: theme,
            child: pageChild,
          );
        }),
      );
    },
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: barrierColor ?? Colors.black54,
    transitionDuration: transitionDuration ?? const Duration(milliseconds: 300),
    transitionBuilder: (context, animation1, animation2, child) {
      return _buildDialogTransitions(
          context, animation1, animation2, child, transitionType);
    },
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
  );
}

Widget _buildDialogTransitions(
    BuildContext context,
    Animation<double> animaton1,
    Animation<double> secondaryAnimation,
    Widget child,
    TwTransitionType type) {
  if (type == TwTransitionType.fade) {
    return FadeTransition(
      opacity: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: animaton1,
        curve: Curves.fastOutSlowIn,
      )),
      child: child,
    );
  } else if (type == TwTransitionType.scale) {
    return ScaleTransition(
      scale: Tween(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animaton1, curve: Curves.fastOutSlowIn)),
      child: child,
    );
  } else if (type == TwTransitionType.rotation) {
    return RotationTransition(
      turns: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: animaton1,
        curve: Curves.fastOutSlowIn,
      )),
      child: ScaleTransition(
        scale: Tween(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animaton1, curve: Curves.fastOutSlowIn)),
        child: child,
      ),
    );
  } else if (type == TwTransitionType.inFromLeft) {
    return SlideTransition(
      position: Tween<Offset>(
              begin: const Offset(-1.0, 0.0), end: const Offset(0.0, 0.0))
          .animate(
              CurvedAnimation(parent: animaton1, curve: Curves.fastOutSlowIn)),
      child: child,
    );
  } else if (type == TwTransitionType.inFromRight) {
    return SlideTransition(
      position: Tween<Offset>(
              begin: const Offset(1.0, 0.0), end: const Offset(0.0, 0.0))
          .animate(
              CurvedAnimation(parent: animaton1, curve: Curves.fastOutSlowIn)),
      child: child,
    );
  } else if (type == TwTransitionType.inFromTop) {
    return SlideTransition(
      position: Tween<Offset>(
              begin: const Offset(0.0, -1.0), end: const Offset(0.0, 0.0))
          .animate(
              CurvedAnimation(parent: animaton1, curve: Curves.fastOutSlowIn)),
      child: child,
    );
  } else if (type == TwTransitionType.inFromBottom) {
    return SlideTransition(
      position: Tween<Offset>(
              begin: const Offset(0.0, 1.0), end: const Offset(0.0, 0.0))
          .animate(
              CurvedAnimation(parent: animaton1, curve: Curves.fastOutSlowIn)),
      child: child,
    );
  } else if (type == TwTransitionType.size) {
    return SizeTransition(
      sizeFactor: Tween<double>(begin: 0.1, end: 1.0)
          .animate(CurvedAnimation(parent: animaton1, curve: Curves.linear)),
      child: child,
    );
  } else {
    return child;
  }
}
