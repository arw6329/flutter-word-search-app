# Infinite word search - flutter word search mobile app

This repository contains an implementation of a basic word search mobile game in Flutter and Dart. I developed this app to learn the basics of Flutter, Dart, and cross-platform app development as well as to gain experience with app publishing and monetization.

All code in this repository, including chiefly the word search generation algorithm and interactive components of the UI, is my own. The only parts of this repository not of my own work are the themed wordlists at [assets/wordlists/ThemedNormal](/assets/wordlists/ThemedNormal), which I downloaded from https://printablecreative.com/word-search/.

I planned to release the app to the Play Store, but Google made changes to individual Play Console accounts created after 2023 that make it difficult for indie or hobbyist developers to publish personal/side projects to the Play Store, so it is not feasible for me to do so.

## Images

![Homepage](/docs/images/homepage.jpg)
![Themed gamemode puzzle](/docs/images/themed-puzzle.jpg)
![Random words gamemode puzzle](/docs/images/random-puzzle.jpg)
![Puzzle being completed](/docs/images/puzzle-solve.gif)
![Completed random words gamemode puzzle](/docs/images/puzzle-complete.jpg)
![Numeric gamemode puzzle](/docs/images/numeric-puzzle.jpg)

## Features

- Dynamic word search generation
- Autosave/load from local storage
- Multiple gamemodes
- Google AdMob integration
- Custom Flutter animations on puzzle completion

## Build and Install to an Android Device

You can build the app as an APK and install directly to an Android device over adb like so:

```
flutter build apk --release
adb install build/app/outputs/flutter-apk/app-release.apk
```

The app will display test ads in banners at the bottom of the page as part of the Google AdMob integration.
You can disable the ads during build like so:

```
flutter build apk --release --dart-define="ADS_ENABLED=false"
```
