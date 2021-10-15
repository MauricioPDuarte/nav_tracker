library nav_tracker;

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'imports/common.dart';
import 'imports/tree.dart';

class NavTracker {
  NavTracker._privateConstructor();

  static final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>();

  static final NavTracker _instance = NavTracker._privateConstructor();
  static NavTracker get instance => _instance;
  static NavTracker get I => _instance;

  bool _inTest = false;
  set inTest(bool v) => _inTest = v;

  GlobalKey<NavigatorState> get navKey => _navigatorKey;

  /// The default transition duration to use throughout Fluro
  static const _defaultTransitionDuration = const Duration(milliseconds: 250);
  Handler? notFoundHandler;
  RouteTree _routeTree = RouteTree();

  void define(String routePath,
      {@required Handler? handler,
      TransitionType? transitionType,
      Duration transitionDuration = _defaultTransitionDuration,
      RouteTransitionsBuilder? transitionBuilder}) {
    _routeTree.addRoute(
      AppRoute(routePath, handler,
          transitionType: transitionType,
          transitionDuration: transitionDuration,
          transitionBuilder: transitionBuilder),
    );
  }

  Route<Null> _notFoundRoute(String path, {bool? maintainState}) {
    RouteCreator<Null> creator = (RouteSettings? routeSettings,
        Map<String, List<String>> parameters, args) {
      return MaterialPageRoute<Null>(
          settings: routeSettings,
          maintainState: maintainState ?? true,
          builder: (BuildContext context) {
            return notFoundHandler?.bind(parameters, args) ?? SizedBox.shrink();
          });
    };
    return creator(RouteSettings(name: path), {}, {});
  }

  /// Attempt to match a route to the provided [path].
  RouteMatch matchRoute(String? path,
      {RouteSettings? routeSettings,
      TransitionType? transitionType,
      Duration? transitionDuration,
      RouteTransitionsBuilder? transitionsBuilder,
      dynamic arguments,
      bool maintainState = true}) {
    RouteSettings settingsToUse = routeSettings ?? RouteSettings(name: path);

    if (settingsToUse.name == null) {
      settingsToUse = settingsToUse.copyWith(name: path);
    }
    AppRouteMatch? match = _routeTree.matchRoute(path!);
    AppRoute? route = match?.route;

    if (transitionDuration == null && route?.transitionDuration != null) {
      transitionDuration = route?.transitionDuration;
    }
    //Atualização 1.0.5
    Handler? handler = (route != null ? route.handler : notFoundHandler);
    TransitionType? transition = transitionType;
    if (transitionType == null) {
      transition = route != null ? route.transitionType : TransitionType.native;
    }
    if (route == null && notFoundHandler == null) {
      return RouteMatch(
          matchType: RouteMatchType.noMatch,
          errorMessage: "No matching route was found");
    }
    Map<String, List<String>> parameters =
        match?.parameters ?? <String, List<String>>{};

    if (handler?.type == HandlerType.function) {
      handler?.bind(parameters, arguments);
      return RouteMatch(matchType: RouteMatchType.nonVisual);
    }

    var resultHanders = handler?.bind(parameters, arguments);
    RouteCreator creator = (RouteSettings? routeSettings,
        Map<String, List<String>> parameters, dynamic arguments) {
      bool isNativeTransition = (transition == TransitionType.native ||
          transition == TransitionType.nativeModal);
      if (isNativeTransition) {
        return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            fullscreenDialog: transition == TransitionType.nativeModal,
            maintainState: maintainState,
            builder: (BuildContext context) {
              return resultHanders ?? SizedBox.shrink();
            });
      } else if (transition == TransitionType.material ||
          transition == TransitionType.materialFullScreenDialog) {
        return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            fullscreenDialog:
                transition == TransitionType.materialFullScreenDialog,
            maintainState: maintainState,
            builder: (BuildContext context) {
              return resultHanders ?? SizedBox.shrink();
            });
      } else if (transition == TransitionType.cupertino ||
          transition == TransitionType.cupertinoFullScreenDialog) {
        return CupertinoPageRoute<dynamic>(
            settings: routeSettings,
            fullscreenDialog:
                transition == TransitionType.cupertinoFullScreenDialog,
            maintainState: maintainState,
            builder: (BuildContext context) {
              return resultHanders ?? SizedBox.shrink();
            });
      } else {
        RouteTransitionsBuilder? routeTransitionsBuilder;

        if (transition == TransitionType.custom) {
          routeTransitionsBuilder =
              transitionsBuilder ?? route?.transitionBuilder;
        } else {
          routeTransitionsBuilder = _standardTransitionsBuilder(transition);
        }

        return PageRouteBuilder<dynamic>(
          settings: routeSettings,
          maintainState: maintainState,
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return resultHanders ?? SizedBox.shrink();
          },
          transitionDuration: transition == TransitionType.none
              ? Duration.zero
              : (transitionDuration ??
                  route?.transitionDuration ??
                  _defaultTransitionDuration),
          reverseTransitionDuration: transition == TransitionType.none
              ? Duration.zero
              : (transitionDuration ??
                  route?.transitionDuration ??
                  _defaultTransitionDuration),
          transitionsBuilder: transition == TransitionType.none
              ? (_, __, ___, child) => child
              : routeTransitionsBuilder!,
        );
      }
    };

    return RouteMatch(
      matchType: RouteMatchType.visual,
      route: creator(settingsToUse, parameters, arguments),
    );
  }

  /// Finds a defined [AppRoute] for the path value. If no [AppRoute] definition was found
  /// then function will return null.
  AppRouteMatch? match(String path) {
    return _routeTree.matchRoute(path);
  }

  Future toReplaceNamed(String path,
      {bool clearStack = false,
      bool maintainState = true,
      bool rootNavigator = false,
      dynamic arguments,
      BuildContext? ctx,
      TransitionType? transition,
      Duration? transitionDuration,
      RouteTransitionsBuilder? transitionBuilder,
      RouteSettings? routeSettings}) {
    return toNamed(path,
        replace: true,
        arguments: arguments,
        clearStack: clearStack,
        maintainState: maintainState,
        rootNavigator: rootNavigator,
        ctx: ctx,
        transition: transition,
        transitionDuration: transitionDuration,
        transitionBuilder: transitionBuilder,
        routeSettings: routeSettings);
  }

  Future toNamed(String path,
      {bool replace = false,
      bool clearStack = false,
      bool maintainState = true,
      bool rootNavigator = false,
      dynamic arguments,
      BuildContext? ctx,
      TransitionType? transition,
      Duration? transitionDuration,
      RouteTransitionsBuilder? transitionBuilder,
      RouteSettings? routeSettings}) {
    if (_inTest) {
      final navigatorTest = Navigator.of((ctx ?? _navigatorKey.currentContext)!,
          rootNavigator: rootNavigator);
      return (replace
          ? navigatorTest.pushReplacementNamed(path)
          : navigatorTest.pushNamed(path));
    }

    RouteMatch routeMatch = matchRoute(path,
        transitionType: transition,
        transitionsBuilder: transitionBuilder,
        transitionDuration: transitionDuration,
        maintainState: maintainState,
        arguments: arguments,
        routeSettings: routeSettings);

    Route<dynamic>? route = routeMatch.route;
    Completer completer = Completer();
    Future future = completer.future;
    if (routeMatch.matchType == RouteMatchType.nonVisual) {
      completer.complete("Non visual route type.");
    } else {
      if (route == null && notFoundHandler != null) {
        route = _notFoundRoute(path, maintainState: maintainState);
      }
      if (route != null) {
        final navigator = Navigator.of((ctx ?? _navigatorKey.currentContext)!,
            rootNavigator: rootNavigator);
        if (clearStack) {
          future = navigator.pushAndRemoveUntil(route, (check) => false);
        } else {
          future = replace
              ? navigator.pushReplacement(route)
              : navigator.push(route);
        }
        completer.complete();
      } else {
        final error = "No registered route was found to handle '$path'.";
        print(error);
        completer.completeError(RouteNotFoundException(error, path));
      }
    }

    return future;
  }

  RouteTransitionsBuilder _standardTransitionsBuilder(
      TransitionType? transitionType) {
    return (BuildContext context, Animation<double> animation,
        Animation<double> secondaryAnimation, Widget child) {
      if (transitionType == TransitionType.fadeIn) {
        return FadeTransition(opacity: animation, child: child);
      } else {
        const Offset topLeft = const Offset(0.0, 0.0);
        const Offset topRight = const Offset(1.0, 0.0);
        const Offset bottomLeft = const Offset(0.0, 1.0);

        Offset startOffset = bottomLeft;
        Offset endOffset = topLeft;
        if (transitionType == TransitionType.inFromLeft) {
          startOffset = const Offset(-1.0, 0.0);
          endOffset = topLeft;
        } else if (transitionType == TransitionType.inFromRight) {
          startOffset = topRight;
          endOffset = topLeft;
        } else if (transitionType == TransitionType.inFromBottom) {
          startOffset = bottomLeft;
          endOffset = topLeft;
        } else if (transitionType == TransitionType.inFromTop) {
          startOffset = Offset(0.0, -1.0);
          endOffset = topLeft;
        }

        return SlideTransition(
          position: Tween<Offset>(
            begin: startOffset,
            end: endOffset,
          ).animate(animation),
          child: child,
        );
      }
    };
  }

  void popUntil(bool Function(Route<dynamic>) predicate) =>
      Navigator.of(_navigatorKey.currentContext!).popUntil(predicate);

  /// Similar to [Navigator.pop]
  void pop<T>([T? result]) =>
      Navigator.of(_navigatorKey.currentContext!).pop(result);

  Route<dynamic>? generator(RouteSettings routeSettings) {
    if (_inTest) {
      return new MaterialPageRoute(
        builder: (context) => Container(),
        settings: routeSettings,
      );
    }
    RouteMatch match =
        matchRoute(routeSettings.name, routeSettings: routeSettings);
    return match.route;
  }

  void resetTree() {
    _routeTree = RouteTree();
  }

  /// Prints the route tree so you can analyze it.
  void printTree() {
    _routeTree.printTree();
  }
}
