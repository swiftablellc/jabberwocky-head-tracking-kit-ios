# Jabberwocky Head Tracking Kit for iOS

The Jabberwocky® Head Tracking Kit (`JabberwockyHTKit`) is an open-source iOS framework, developed by Swiftable LLC, that provides a touch-free interface for existing iOS applications. Jabberwocky enables users to interact with an application by just moving their head. Head movement translates into the movement of a mouse-like cursor on the screen. By default, blinks trigger a `.touchUpInside` event simulating a tap on any `UIControl` subclass (in fact any subclass of `UIView` can be extended to respond to a facial gesture trigger).

Jabberwocky was originally designed as an **accessibility tool** for users with mobility impairments such as ALS or Spinal Cord Injury (SCI) to enable effective and efficient interaction with iOS devices. Currently, Jabberwocky requires [ARKit](https://developer.apple.com/augmented-reality/arkit/) and is only supported on devices that also support [FaceID](https://support.apple.com/en-us/HT208108). Supported devices include:
* iPhone X and later models
* iPad Pro models with the A12X Bionic chip

As of iOS 13, Head Tracking Accessibility was added to [iOS Switch Control](https://support.apple.com/en-us/HT201370#usesc) for the same device models supported by Jabberwocky. It is important to note that iOS Head Tracking can be configured to operate in a similar capacity to Jabberwocky Head Tracking, but is provided at the OS level. While iOS Head Tracking Accessibility works across the entire device, highlighting Jabberwocky's  limitation to in-app only, its tight coupling with Switch Control, complicated setup, and limited feature set make it unsuitable for many users. Jabberwocky supports in-app customization of Head Tracking and provides custom event hooks.

## Build/Run JabberwockyHTKit from Source
`JabberwockyHTKit` uses CocoaPods to install its one dependency `JabberwockyHTKitCore`, but the `JabberwockyHTKitCore.framework` can be found [here](https://github.com/swiftablellc/jabberwocky-head-tracking-kit-core-ios-binary/tree/master/JabberwockyHTKitCore.framework).

* Check out from source:

```shell script
git clone git@github.com:swiftablellc/jabberwocky-head-tracking-kit-ios.git && cd jabberwocky-head-tracking-kit-ios.git
```

* Install dependencies using CocoaPods. Install [CocoaPods](https://guides.cocoapods.org/using/getting-started.html) if you haven't already:

```shell script
pod install
```

* Open XCode using the `JabberwockyHTKit.xcworkspace` that was just generated by Cocoapods. *If you open using `.xcodeproj` you will get an error!*

### Build JabberwockyHTKit

* Select the `JabberwockyHTKit` scheme and any Device/Simulator and then run in XCode.

### Run Basic Tutorial

* Select the `BasicTutorial` scheme and run on a `FaceID` enabled device.
    * This uses the pod install of `JabberwockyHTKitCore` but uses the local build of `JabberwockyHTKit` from source.

### Other Schemes
* `*-LocalDev` schemes are for development of `JabberwockyHTKit` and `JabberwockyHTKitCore` simultaneously. This is not a common use case, so it is safe to ignore these schemes.
* `*-PodsOnly` schemes pull all dependencies from CocoaPods and therefore are not very useful for local development.

## CocoaPods Installation in an App
TODO

## Applications
`JabberwockyHTKit` is currently being used by the following applications in the [App Store](https://apps.apple.com/):
* [Jabberwocky AAC](https://apps.apple.com/us/app/jabberwocky/id1438561966) - A touch-free text-to-speech app (Free).
* [Jabberwocky Browser](https://apps.apple.com/us/app/jabberwocky-browser/id1455137144) - A touch-free web browser (Free).

## Dependencies

While `JabberwockyHTKit` is open-source and licensed under the [Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0), it depends on `JabberwockyHTKitCore` which is closed-source and licensed under the [Permissive Binary License](https://www.mbed.com/en/licenses/permissive-binary-license/). `JabberwockyHTKitCore` is free to redistribute in its binary form, without modification, provided the conditions of the license are met.

Both `JabberwockyHTKit` and `JabberwockyHTKitCore` are available in the [Jabberwocky CocoaPods Spec Repo](https://github.com/swiftablellc/jabberwocky-specs-repo) and may be pushed to the master CocoaPods repo in the future.


## Trademarks
Jabberwocky® is a registered trademark of Swiftable LLC.

## License
[Apache 2.0 License](LICENSE)
