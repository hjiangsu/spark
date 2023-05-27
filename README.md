
<h1 align="center">
  <br>
    <img src="./assets/logo_transparent.png" alt="Markdownify" width="200">
  <br>
  Spark
  <br>
</h1>

<h4 align="center">
    An open source, cross-platform Reddit client built with <a href="https://flutter.dev/" target="_blank">Flutter</a>.
</h4>

<p align="center">
  <a href="">
    <img src="https://img.shields.io/github/license/hjiangsu/spark" alt="License">
  </a>
    <a href="">
    <img src="https://img.shields.io/github/forks/hjiangsu/spark" alt="Forks">
  </a>
    <a href="">
    <img src="https://img.shields.io/badge/platform-ios%20%7C%20android-blueviolet" alt="Platforms">
  </a>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#roadmap">Roadmap</a> •
  <a href="#contributions">Contributing</a> •
  <a href="#contributions">Conventions</a> •
  <a href="#license">Related Packages</a>
</p>

## Features
Spark is currently under heavy and active development. Some current features include:
- Ability to browse and search for subreddits
- Ability to see post information and comments
- Ability to authenticate with Reddit via OAuth to obtain user feeds and subreddits

## Roadmap
- Increased native platform support for Windows, MacOS, and Linux
- Native biometrics support and security 

## Contributing
Contributions are always welcomed here! To contribute features or bug-fixes:
1. Fork this repository
2. Make your changes and additions
3. Create a pull request to have your changes reviewed

More information regarding contributions will be added in the future.

## Build
Building the release files depends on the platform.
- iOS: `flutter build ios --release`
- Android: `flutter build apk`

Note: If Sentry is used for collecting error information, the corresponding debug symbols must be uploaded. This can be done using the following command: `flutter packages pub run sentry_dart_plugin`

## Conventions
This section lists some of the conventions used by the project to keep consistent behaviour and layouts.

### File Structure
The file structure is separated mainly by features. Each feature of the application will be hosted in its corresponding directory. For example, logic related to a Feed will be under the `lib/feed` directory.

Shared logic across features will be located under `lib/`. For example:
- Shared widgets will be located under `lib/widgets`.
- Shared enums will be located under `lib/enums`.

### BLoC
This project uses BLoC as the state management library for most actions. Spark currently uses the following packages for handling state management:
- [bloc](https://github.com/felangel/bloc/tree/master/packages/bloc) - handles general BLoC implementation schemes
- [bloc_test](https://github.com/felangel/bloc/tree/master/packages/bloc_test) - handles testing of BLoC related logic
- [bloc_concurrency](https://github.com/felangel/bloc/tree/master/packages/bloc_concurrency) - handles custom event transformers for BLoC related logic
- [flutter_bloc](https://github.com/felangel/bloc/tree/master/packages/flutter_bloc) - handles integration of BLoCs into Flutter

To learn more about BLoC and how it is used in Spark, reference the official [docs](https://bloclibrary.dev/#/).

## Related Packages

[reddit-dart](https://github.com/hjiangsu/reddit-dart) - Custom Reddit library built in Dart.