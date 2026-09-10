# Flutter 3 upgrade

The project now targets Flutter **3.44.7 stable / Dart 3.12.2**. This is the
installed validation baseline, not a claim to use the newest Flutter release.
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
- Gradle 9.1 / AGP 9.0.1 / Java 17, plugin DSL, SDK levels supplied by Flutter,
  and modern Android application registration. Debug builds no longer require
  a private release keystore. Release builds are unsigned unless the existing
  ignored `android/key.properties` supplies a real signing configuration.
- iOS minimum target raised from 9 to 13; removed the old custom CocoaPods
  installer override and outdated native lockfile. Version values now come
  from Flutter's build name and build number.
- Removed the unused `_DeMarkChart.dart` experiment, which rendered no series
  and incorrectly treated numeric prices as `dart:ffi` values.

## Platform validation and limitations

Android uses `android.builtInKotlin=false` and `android.newDsl=false` for Flutter
3.44 compatibility. Full built-in Kotlin requires Flutter 3.47 or newer; migrate
the application and check every native plugin together at that upgrade.
See [Flutter's Kotlin migration guide](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers)
and [Gradle plugin DSL migration](https://docs.flutter.dev/release/breaking-changes/flutter-gradle-plugin-apply).

The app still depends on the original external stock and gallery services.
Bundled chart HTML is local; its market data is not. Automated tests use fixtures
and do not certify live market data, historical strategy accuracy or backend
availability. Existing HTTP service compatibility settings remain in place.

On macOS, run `flutter pub get`, then `cd ios && pod install`, and commit the
regenerated `Podfile.lock` after verification. Run
`flutter build ios --simulator --debug` and exercise WebView navigation and
chart asset loading in the simulator. Windows cannot validate Xcode builds.

Before a release, test report navigation, chart gestures, gallery links and
back/forward navigation on Android and iOS devices. Configure release signing
separately. No store upload is part of this migration.

## Validation on 2026-09-10

- `flutter analyze`: passed with no issues.
- `flutter test`: all 11 tests passed, including an actual loopback asset request.
- `flutter build apk --debug`: passed; debug APK generated locally.
- Live menu and RPS HTTPS probes failed TLS connection establishment on this
  machine; this is not evidence that the remote services are universally down.
- No Android device was connected. iOS/Xcode validation remains a macOS step.
