# Jabberwocky Head Tracking Kit for iOS

The Jabberwocky® Head Tracking Kit (`JabberwockyHTKit`) is an open-source iOS framework, developed by Swiftable LLC, that provides a touch-free interface for existing iOS applications. Jabberwocky enables users to interact with an application by just moving their head. Head movement translates into the movement of a mouse-like cursor on the screen. By default, blinks trigger a `.touchUpInside` event simulating a tap on any `UIControl` subclass (in fact any subclass of `UIView` can be extended to respond to a facial gesture trigger).

Jabberwocky was originally designed as an **accessibility tool** for users with mobility impairments such as ALS or Spinal Cord Injury (SCI) to enable effective and efficient interaction with iOS devices. Currently, Jabberwocky requires [ARKit](https://developer.apple.com/augmented-reality/arkit/) and is only supported on devices that also support [FaceID](https://support.apple.com/en-us/HT208108). Supported devices include:
* iPhone X and later models
* iPad Pro models with the A12X Bionic chip

As of iOS 13, Head Tracking Accessibility was added to [iOS Switch Control](https://support.apple.com/en-us/HT201370#usesc) for the same device models supported by Jabberwocky. It is important to note that iOS Head Tracking can be configured to operate in a similar capacity to Jabberwocky Head Tracking, but is provided at the OS level. While iOS Head Tracking Accessibility works across the entire device, highlighting Jabberwocky's  limitation to in-app only, its tight coupling with Switch Control, complicated setup, and limited feature set make it unsuitable for many users. Jabberwocky supports in-app customization of Head Tracking and provides custom event hooks.

## Applications
`JabberwockyHTKit` is currently being used by the following applications in the [App Store](https://apps.apple.com/):
* [Jabberwocky AAC](https://apps.apple.com/us/app/jabberwocky/id1438561966) - A touch-free text-to-speech app (Free).
* [Jabberwocky Browser](https://apps.apple.com/us/app/jabberwocky-browser/id1455137144) - A touch-free web browser (Free).

## Dependencies

While `JabberwockyHTKit` is open-source and licensed under the [Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0), it depends on `JabberwockyHTKitCore` which is closed-source and licensed under the [Permissive Binary License](https://www.mbed.com/en/licenses/permissive-binary-license/). `JabberwockyHTKitCore` is free to redistribute in its binary form, without modification, provided the conditions of the license are met.

Both `JabberwockyHTKit` and `JabberwockyHTKitCore` are available in the [Jabberwocky CocoaPods Spec Repo](https://github.com/swiftablellc/jabberwocky-specs-repo) and may be pushed to the master CocoaPods repo in the future.


## Trademarks
Jabberwocky® is a [registered trademark](http://tmsearch.uspto.gov/bin/showfield?f=doc&state=4810:1r62r7.2.1) of Swiftable LLC.
