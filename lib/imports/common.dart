/*
 * fluro
 * Created by Yakka
 * https://theyakka.com
 * 
 * Copyright (c) 2019 Yakka, LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:flutter/widgets.dart';

/// The type of the handler, whether it's a buildable route or
/// a function that is called when routed.
enum HandlerType {
  route,
  function,
}

/// The handler to register with [FluroRouter.define]
class Handler {
  Handler({this.type = HandlerType.route, required this.bind});
  final HandlerType type;
  final Bind bind;
}

/// A function that creates new routes.
typedef Route<T> RouteCreator<T>(
    RouteSettings route, Map<String, List<String>> parameters, dynamic args);

/// Builds out a screen based on string path [parameters].
///
/// Note: you can access [RouteSettings]
typedef Widget? Bind(Map<String, List<String>> params, dynamic args);

/// A route that is added to the router tree.
class AppRoute {
  String route;
  dynamic handler;
  TransitionType? transitionType;
  Duration? transitionDuration;
  RouteTransitionsBuilder? transitionBuilder;
  AppRoute(this.route, this.handler,
      {this.transitionType, this.transitionDuration, this.transitionBuilder});
}

/// The type of transition to use when pushing/popping a route.
///
/// [TransitionType.custom] must also provide a transition when used.
enum TransitionType {
  native,
  nativeModal,
  inFromLeft,
  inFromTop,
  inFromRight,
  inFromBottom,
  fadeIn,
  custom,
  material,
  materialFullScreenDialog,
  cupertino,
  cupertinoFullScreenDialog,
  none,
}

/// The match type of the route.
enum RouteMatchType {
  visual,
  nonVisual,
  noMatch,
}

/// The route that was matched.
class RouteMatch {
  RouteMatch(
      {this.matchType = RouteMatchType.noMatch,
      this.route,
      this.errorMessage = "Unable to match route. Please check the logs."});
  final Route<dynamic>? route;
  final RouteMatchType matchType;
  final String errorMessage;
}

/// When the route is not found.
class RouteNotFoundException implements Exception {
  final String message;
  final String path;
  RouteNotFoundException(this.message, this.path);

  @override
  String toString() {
    return "No registered route was found to handle '$path'";
  }
}
