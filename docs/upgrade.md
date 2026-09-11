# Flutter 3 upgrade

The project now targets Flutter **3.47.3 stable / Dart 3.13.3**, the latest stable
release verified against Flutter's official stable branch and tag on 2026-09-11.
The SDK is pinned in `.fvmrc`; install it with FVM or use a matching local SDK.

## Development

```sh
flutter pub get
dart run build_runner build
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

With FVM, run `fvm install` first and use `fvm flutter` / `fvm dart` for these
commands so the project pin is used even when the global SDK is older.

Run Flutter commands sequentially. Commit generated model files and
`pubspec.lock` when changing models or dependencies. The Dart package remains
`foo` to preserve existing imports; Android application ID remains
`cn.frank.flutter.pilot` and iOS bundle ID remains `com.qianyitian.hope2`.

## Migration scope

- Sound null safety, checked JSON decoding and defaults for optional fields.
- Current compatible package resolution, including explicit `http` and `intl`
  dependencies. `community_charts_flutter` replaces the original charts package
  while retaining the two return series, date axis, legend and selection.
- WebView 4 controllers, page-owned loading/error state and navigation controls.
- A page-owned loopback asset server replaces Jaguar. It uses an ephemeral
  port, serves only the bundled chart directory, and closes with the page.
- Bounded HTTP requests, offline menu fallback, report failure/retry/empty states,
  URL query encoding, checked backtest payloads and stale-response protection.
- Gallery previews load outside `build`; controllers are disposed. The old
  image download button called an unimplemented function that always returned
  false. It now explicitly opens the original image in an external app;
  saving images to the device library is not implemented. Server-side gallery
  download requests remain available.
- Gradle 9.3.1 / AGP 9.1.0 / Java 17, plugin DSL, SDK levels supplied by Flutter,
  and modern Android application registration. Debug builds no longer require
  a private release keystore. Release builds are unsigned unless the existing
  ignored `android/key.properties` supplies a real signing configuration.
- iOS minimum target raised from 9 to 15 to match Flutter 3.47's migration;
  AppDelegate and Info.plist now use the UIScene lifecycle and implicit-engine
  plugin registration. Removed the old custom CocoaPods
  installer override and outdated native lockfile. Version values now come
  from Flutter's build name and build number.
- Removed the unused `_DeMarkChart.dart` experiment, which rendered no series
  and incorrectly treated numeric prices as `dart:ffi` values.

## Platform validation and limitations

Android uses Kotlin plugin 2.4.0 with `android.builtInKotlin=false` and
`android.newDsl=false`. Flutter 3.47.3 currently rejects AGP's built-in Kotlin
2.2.10 as lower than Flutter's own 2.2.20 minimum, an upstream issue also
reported against newer AGP versions ([flutter/flutter#192167](https://github.com/flutter/flutter/issues/192167)).
This compatibility mode keeps AGP 9.1 and Gradle 9.3.1 without bypassing Flutter's
dependency validation. Remove the opt-out and explicit Kotlin plugin after the
upstream issue and native plugins are fixed. The SDK is installed separately
for this project; the machine's existing Flutter installation is not changed.
See [Flutter's Kotlin migration guide](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers)
and [Gradle plugin DSL migration](https://docs.flutter.dev/release/breaking-changes/flutter-gradle-plugin-apply).

The app still depends on the original external stock and gallery services.
Bundled chart HTML is local; its market data is not. Automated tests use fixtures
and do not certify live market data, historical strategy accuracy or backend
availability. Existing HTTP service compatibility settings remain in place.

External gallery and stock-search endpoints now use HTTPS. The bundled chart
server remains HTTP on loopback only because it serves local WebView assets.

On macOS, run `flutter pub get`, then `cd ios && pod install`, and commit the
regenerated `Podfile.lock` after verification. Run
`flutter build ios --simulator --debug` and exercise WebView navigation and
chart asset loading in the simulator. Windows cannot validate Xcode builds.

Before a release, test report navigation, chart gestures, gallery links and
back/forward navigation on Android and iOS devices. Configure release signing
separately. No store upload is part of this migration.

## Validation on 2026-09-11 (Flutter 3.47.3)

- `flutter analyze`: passed with no issues.
- `flutter test`: all 11 tests passed, including an actual loopback asset request.
- `flutter build apk --debug`: passed; debug APK generated locally.
- `flutter analyze --suggestions`: Java, Gradle, Kotlin plugin and Android
  Gradle plugin versions reported compatible.
- Live menu and RPS HTTPS probes failed TLS connection establishment on this
  machine; this is not evidence that the remote services are universally down.
- No Android device was connected. iOS/Xcode validation remains a macOS step.
