import 'package:flutter_test/flutter_test.dart';
import 'package:nav_tracker/imports/common.dart';
import 'package:nav_tracker/imports/tree.dart';

import 'package:nav_tracker/nav_tracker.dart';

void main() {
  NavTracker? router;
  setUp(() {
    router = NavTracker.I;
  });
  test("NavTracker correctly parses named parameters", () async {
    router!.resetTree();
    String path = "/users/1234";
    String route = "/users/:id";
    router!.define(route, handler: null);
    AppRouteMatch? match = router!.match(path);
    expect(
        match?.parameters,
        equals(<String, List<String>>{
          "id": ["1234"],
        }));
  });

  test("NavTracker correctly parses named parameters with query", () async {
    router!.resetTree();
    String path = "/users/1234?name=luke";
    String route = "/users/:id";

    router!.define(route, handler: null);
    AppRouteMatch? match = router!.match(path);
    expect(
        match?.parameters,
        equals(<String, List<String>>{
          "id": ["1234"],
          "name": ["luke"],
        }));
  });

  test("NavTracker correctly parses query parameters", () async {
    router!.resetTree();

    String path = "/users/create?name=luke&phrase=hello%20world&number=7";
    String route = "/users/create";

    router!.define(route, handler: null);
    AppRouteMatch? match = router!.match(path);

    expect(
        match?.parameters,
        equals(<String, List<String>>{
          "name": ["luke"],
          "phrase": ["hello world"],
          "number": ["7"],
        }));
  });

  test("NavTracker correctly parses array parameters", () async {
    router!.resetTree();
    String path =
        "/users/create?name=luke&phrase=hello%20world&number=7&number=10&number=13";
    String route = "/users/create";
    router!.define(route, handler: null);
    AppRouteMatch? match = router!.match(path);
    expect(
        match?.parameters,
        equals(<String, List<String>>{
          "name": ["luke"],
          "phrase": ["hello world"],
          "number": ["7", "10", "13"],
        }));
  });

  test("NavTracker correctly matches route and transition type", () async {
    router!.resetTree();
    String path = "/users/1234";
    String route = "/users/:id";

    router!.define(route,
        handler: null, transitionType: TransitionType.inFromRight);
    AppRouteMatch? match = router!.match(path);
    expect(TransitionType.inFromRight, match?.route.transitionType);
  });
}
