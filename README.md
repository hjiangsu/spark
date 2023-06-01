
<h1 align="center">
  <br>
    <img src="./assets/logo_transparent.png" alt="Markdownify" width="200">
  <br>
  Spark
  <br>
</h1>

<h4 align="center">
    An open source, cross-platform Reddit client built with <a href="https://flutter.dev/" target="_blank">Flutter</a>
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
  <a href="#roadmap">Roadmap</a>
 
</p>

<p align="center">
   <a href="#contributing">Contributing</a> •
  <a href="#building">Building</a> •
  <a href="#conventions">Conventions</a> •
  <a href="#related-packages">Related Packages</a>
</p>

## Features
Spark is still under **development**, and all features may not be present yet. The following features are currently implemented.

#### **Subreddits & Feeds**
- Browse front pages including _r/popular_ and _r/all_
- Ability to sort feeds and subreddits by **best**, **hot**, **new**, and **rising**
- Ability to search for a specific subreddit

#### **Posts**
- Browse post and view associated comments
- Upvote, downvote, and save posts (if logged in via OAuth)
- Video autoplay when scrolling into view

#### **Authentication**
- Ability to authenticate via OAuth through Reddit
- View subscribed subreddits

#### **Theme & Customization**
- Ability to change theme colours
- Ability to adjust font sizes

## Roadmap
Currently, work is in progress to add in more support for user actions when logged in. Some features on the roadmap are listed below.
- See post awards
- Increased native platform support for Windows, MacOS, and Linux

## Contributing
Contributions are always welcome! To contribute potential features or bug-fixes:
1. Fork this repository
2. Apply any changes and/or additions
3. Create a pull request to have your changes reviewed and merged

## Building
To build the app from source, a few steps are required.
1. Create a `.env` file in the root directory where `pubspec.yaml` is located.
   - A template is provided under `.env-example` that can be filled in.
3. Set up and install Flutter. For more information, visit https://docs.flutter.dev/get-started/install
4. Obtain the dependencies using `flutter pub get`
5. Run the appropriate build command depending on the platform.
   - iOS: `flutter build ios --release`
   - Android: `flutter build apk`

Note: If Sentry is used for collecting error information, the corresponding debug symbols must be uploaded. This can be done using the following command: `flutter packages pub run sentry_dart_plugin`

## Conventions
While there are no specific conventions that must be followed, do try to follow best practices whenever possible.

## Related Packages

[reddit-dart](https://github.com/hjiangsu/reddit-dart) - Custom Reddit library built in Dart.  
[imgur-dart](https://github.com/hjiangsu/imgur-dart) - Custom Imgur library built in Dart.
