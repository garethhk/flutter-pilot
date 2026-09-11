# Application architecture

The app follows a small layered structure. Dependencies point inward and the
UI does not construct network clients or decide how remote data is merged.

```text
MyApp -> AppDependencies -> one shared ApiClient
AppDependencies -> MenuRepository / services / AppRouter
Feature widgets -> AsyncState<T> -> feature screens
```

`lib/core` contains shared primitives, logging and the dependency graph.
`lib/services` contains data access and repository interfaces. `lib/models`
contains immutable JSON/domain values. Screen implementations live under their
`lib/features` boundary. `lib/navigation` owns route selection and screen
construction.

`AppDependencies` creates one `ApiClient`, passes it to every service and router,
and owns its lifetime. `MyApp.dispose` closes the graph. Widgets require their
dependencies and never create HTTP clients. `AppRouter` is an injected instance,
so route construction cannot create hidden services or transports.

New features must pass repositories through `AppDependencies` and widget
constructors, represent async UI with `AsyncLoading`, `AsyncData`, and
`AsyncError`, keep route mapping in `AppRouter`, and add a widget test using a
fake repository. Models should remain immutable. Unhandled framework, platform
and async failures go through the injected `AppLogger`; `ApiClient` logs failed
requests without response bodies or credentials.

The project includes Flutter's recommended lint set plus lifecycle and Future
handling rules. Run `dart format`, `flutter analyze` and `flutter test` before
pushing changes.

External service URLs must use HTTPS. The only intentional HTTP URL is the
loopback chart server at `127.0.0.1`, which never leaves the device. Android's
network security policy and iOS ATS allow local networking while denying general
cleartext transport.
