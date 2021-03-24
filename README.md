## NavTracker is based on codes from the package Fluro 
 
### But is optimized to navigation without context

Fluro github: https://github.com/lukepighetti/fluro

The brightest, hippest, coolest router for Flutter.

## Features

- Simple route navigation
- Function handlers (map to a function instead of a route)
- Wildcard parameter matching
- Querystring parameter parsing
- Common transitions built-in
- Simple custom transition creation
- Follows `beta` Flutter channel
- Null-safety

## Example Project

There is a pretty sweet example project in the `example` folder. Check it out. Otherwise, keep reading to get up and running.

## Getting started

First, you should define a new `FluroRouter` object by initializing it as such:

```dart
   return MaterialApp(
      title: 'Flutter Demo',
      navigatorKey: NavTracker.I.navKey,
      home: Tela1(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
```

It may be convenient for you to store the router globally/statically so that
you can access the router in other areas in your application.

After instantiating the router, you will need to define your routes and your route handlers:

```dart
void defineRoutes() {
   NavTracker.I.define("user/:id", handler: Handler(bind: (params, args) {
      return UsersScreen(params, args);
    }), transitionType: TransitionType.inFromRight);
}
```

In the above example, the router will intercept a route such as
`/users/1234` and route the application to the `UsersScreen` passing
the value `1234` as a parameter to that screen.

## Navigating

You can use `FluroRouter` with the `MaterialApp.onGenerateRoute` parameter
via `FluroRouter.generator`. To do so, pass the function reference to
the `onGenerate` parameter like: `onGenerateRoute: router.generator`.

You can then use `Navigator.push` and the flutter routing mechanism will match the routes
for you.

You can also manually push to a route yourself. To do so:

```dart
NavTracker.I.toNamed("/users/1234");
```

## Class arguments

Don't want to use strings for params? No worries.

After pushing a route with a custom `RouteSettings` you can use the `BuildContext.settings` extension to extract the settings. Typically this would be done in `Handler.handlerFunc` so you can pass `RouteSettings.arguments` to your screen widgets.

```dart
/// Push a route with custom RouteSettings if you don't want to use path arguments
NavTracker.I.toNamed(
  'home',
  arguments: {"test": 5598745},
);

/// Extract the arguments using [BuildContext.settings.arguments] or [BuildContext.arguments] for short
var homeHandler = Handler(
  handlerFunc: (params, arguments) {
    final args = arguments;
    return HomeComponent(args);
  },
);
```
