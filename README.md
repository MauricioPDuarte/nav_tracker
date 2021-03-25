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



## Getting started

First, you should define a new `NavTracker` object by initializing it as such:

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

You can use `NavTracker` with the `MaterialApp.onGenerateRoute` parameter
via `NavTracker.I.generator`. To do so, pass the function reference to
the `onGenerate` parameter like: `onGenerateRoute: NavTracker.I.generator`.

You can then use `Navigator.push` and the flutter routing mechanism will match the routes
for you.

You can also manually push to a route yourself. To do so:

```dart
NavTracker.I.toNamed("/users/1234");
```

## Class arguments

After pushing a route with a custom `arguments`. You can get arguments on second parameter from `Handler.bind` callback. 

```dart
/// Push a route with custom arguments.
NavTracker.I.toNamed(
  'home',
  arguments: {"test": 5598745},
);

/// Extract the arguments using [arguments]
var homeHandler = Handler(
  bind: (params, arguments) {
    final args = arguments;
    return HomeComponent(args);
  },
);
```
