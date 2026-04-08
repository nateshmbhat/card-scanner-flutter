# Changelog

## 1.0.4
- Fix crash when pressing back during scan timeout on Android and iOS
- Add configurable prompt text via `CardScanOptions.prompt` parameter
- Add flashlight toggle button to Android scanner UI
- Remove debug print that logged sensitive card data
- Upgrade ML Kit text recognition: iOS >= 6.0.0, Android 19.0.1
- Upgrade CameraX to stable 1.3.4, appcompat to 1.6.1, constraintlayout to 2.1.4
- Bump iOS minimum deployment target to 15.0
- Replace deprecated jcenter() with mavenCentral() on Android

## 1.0.3
- Updated iOS dependencies to resolve version conflicts with Firebase and Google Sign-In
- Updated GoogleMLKit/TextRecognition to version ~> 3.2.0 for better compatibility
- Updated minimum iOS deployment target to 12.0 in podspec to match README requirements
- Improved iOS simulator architecture support for Apple Silicon Macs

## 1.0.2
- upgraded gradle versions and compatibility versions to support newer versions of dart & flutter sdk

#### 1.0.1-prerelease
- ios bug fix

## 1.0.0-prerelease
+ migrating to null safety

## 0.2.1
+ Adds many options to control scanning behavior
+ improved card holder name scanning and expiry date scanning accuracy
+ refactored major part of code
+ added example app and parameter customization ui to fully customize any parameter during run time and find the best options that suit your needs
+ added back button to the scanner screen


## 0.1.0
+ Added IOS support 🥳
+ Still Better accuracy and speed of scanning ✅
+ refactored example app 📖


### 0.0.4
* Much Better accuracy in card holder name and expiry date scanning ✅
+ Improved speed of scanning 🏎


## 0.0.1
* First Release
