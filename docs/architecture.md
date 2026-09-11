# Application architecture

The app follows a small layered structure. Dependencies point inward and the
UI does not construct network clients or decide how remote data is merged.

```text
MyApp -> AppDependencies -> MenuRepository -> ConfigService -> ApiClient
Feature widgets -> AsyncState<T>
Feature widgets -> AppRouter -> feature screens
```

`lib/core` contains shared primitives and the dependency graph. `lib/services`
contains data access and repository interfaces. `lib/models` contains immutable
JSON/domain values. `lib/features` is the public entry point for feature modules;
existing screen files remain under `containers` during incremental migration.
`lib/navigation` owns route selection and screen construction.

New features must pass repositories through `AppDependencies` and widget
constructors, represent async UI with `AsyncLoading`, `AsyncData`, and
`AsyncError`, keep route mapping in `AppRouter`, and add a widget test using a
fake repository. Models should remain immutable. Run `flutter analyze` and
`flutter test` before pushing changes.
