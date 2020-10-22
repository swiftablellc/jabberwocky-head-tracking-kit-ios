# Jabberwocky Head Tracking Kit for iOS
![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/swiftablellc/jabberwocky-head-tracking-kit-ios?label=release&sort=semver) ![Platform](https://img.shields.io/badge/platform-iOS-lightgrey) ![GitHub](https://img.shields.io/github/license/swiftablellc/jabberwocky-head-tracking-kit-ios) 

> Head Tracking Cursor for any iOS app!

![htkit-demo](https://user-images.githubusercontent.com/6625903/82473198-d5ba2080-9a8e-11ea-9c2a-379558bf8b65.gif)

## Features

* Head Tracking Cursor
* Blink or Dwell Click
* Easy to use Settings
* < 10 Line Configuration for Existing Apps
* Compatible with simulator (will not enable)
* Compatible with iOS Deployment targets 9.0 and above.
  * Currently enableable on iOS 11.0 and above.
* Interaction with existing UI elements: 
  * `UIControl`
  * `UICollectionViewCell`
  * `UITableViewCell`
  * Extensible for subclasses of `UIView`
* Plugin Architecture (HTFeature)

## Build JabberwockyHTKit from Source

To build and run `JabberwockyHTKit` from source follow the steps below. `BasicTutorial` is an example application target that has one standard `UIButton` which responds to taps on the screen. When configuring head tracking within an existing application there are a few setup steps that need to be performed. Once `JabberwockyHTKit` is configured and enabled, the default `HTFeature` singletons that are configured will automatically detect `UIControl`, `UICollectionViewCell`, and `UITableViewCell` elements and interact with them. Other custom `UIView` elements can be configured to work with the head tracking framework by implementing the `HTFocusable` protocol.

### Step 1: Checkout

* Check out from source:

```shell script
git clone git@github.com:swiftablellc/jabberwocky-head-tracking-kit-ios.git && cd jabberwocky-head-tracking-kit-ios.git
```

### Step 2: Build Framework

* Open XCode using the `JabberwockyHTKit.xcodeproj`
* Select the `JabberwockyHTKit` scheme and any Device/Simulator and then run in XCode.

### Step 3: Run Tutorial

* Select the `BasicTutorial` scheme and run on a `FaceID` enabled device.

### Notes

* `*-LocalDev` schemes are for development of `JabberwockyHTKit` and `JabberwockyARKitEngine` simultaneously. This is not a common use case, so it is safe to ignore these schemes.
* `*-PodsOnly` schemes pull all dependencies from CocoaPods and therefore are not very useful for local development of `JabberwockyHTKit`, but a great way to try out see how cocoapods would work in an existing application. To use these, you will need to do a `pod install` and open xcode using the `.xcworkspace` file.

## Add Head Tracking to an Existing Application

### Step 1: Install JabberwockyHTKit Frameworks

* Create a `Podfile` and replace `$YOUR_TARGET` with the appropriate target:

```shell script
source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

platform :ios, '12.0'

target '$YOUR_TARGET' do
  pod 'JabberwockyHTKit', '~> 0.8.3'
end
```

* Install dependencies using CocoaPods. Install [CocoaPods](https://guides.cocoapods.org/using/getting-started.html) if you haven't already:

```shell script
pod install
```
* *WARNING:* Don't forget to open your project using the `*.xcworkspace` instead of  `.xcodeproj` or you will get a Pods not found error.

### Step 2: Add Camera Permissions to *-Info.plist

* Add `NSCameraUsageDescription` to your `$PROJECT-Info.plist` file
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
...
    <key>NSCameraUsageDescription</key>
    <string>Uses Camera to provide Head Tracking</string>
...
</dict>
</plist>
```

### Step 3: Configure JabberwockyHTKit in Code

* Head Tracking can be configured and enabled in code any time after the application `didFinishLaunchingWithOptions`.

#### Swift

* See [Basic Tutorial AppDelegate](Tutorials/BasicTutorial/AppDelegate.swift) for example implementation.
```swift
import AVFoundation
import JabberwockyARKitEngine
import JabberwockyHTKit

...

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AVCaptureDevice.requestAccess(for: .video) { (granted) in
            if (granted) {
                // Configure the default HTFeatures and enable Head Tracking
                DispatchQueue.main.async {
                    HeadTracking.configure(withEngine: ARKitHTEngine.self)
                    HeadTracking.shared.enable()
                }
            } else {
                NSLog("Head Tracking requires camera access.")
            }
        }
        return true
    }
```

* *WARNING:* If you are building a newer Swift project (with `SceneDelegate`), you will need to modifiy an additional file! The engine will get configured correctly, but the head tracking cursor won't show up because the `UIWindowScene` was not assigned correctly. Modify `SceneDelegate.swift` as follows:

```swift
import JabberwockyHTKit

...

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        if let windowScene = scene as? UIWindowScene {
            HeadTracking.shared.windowScene = windowScene
        }
    }
```

#### [SwiftUI](https://developer.apple.com/xcode/swiftui/)

* SwiftUI is only partially supported (introspection and programmatic triggering of events in SwiftUI is elusive at this point). For an example implementation, which is very similar to pre-iOS 13 Swift is available at [SwiftUI Tutorial SceneDelegate](Tutorials/SwiftUITutorial). The `UIWindowScene` needs to be provided to the Jabberwocky `HeadTracking` singleton for Jabberwocky to manage `UIWindow` stacks properly.
* SwiftUI integration requires both of `AppDelegate.swift` and `SceneDelegate.swift` changes documented above...

#### Objective C

* See [Objc Tutorial AppDelegate](Tutorials/ObjcTutorial/AppDelegate.m) for example implementation.

```objc
#import <AVFoundation/AVFoundation.h>
#import <JabberwockyARKitEngine/JabberwockyARKitEngine.h>
#import <JabberwockyHTKit/JabberwockyHTKit.h>

...

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        NSLog(@"Requested Camera Permission");
        if(granted){
            dispatch_async(dispatch_get_main_queue(), ^{
                [HeadTracking configureWithEngine:[ARKitHTEngine class] withFeatures:HeadTracking.DEFAULT_FEATURES withSettingsAppGroup:nil];
                [HeadTracking.shared enableWithCompletion: ^(BOOL success) {}];
            });
        } else {
            NSLog(@"Camera Permissions Missing for Head Tracking");
        }
    }];
    return YES;
}
```

### Step 4: Run

* If you run on a physical device that supports FaceID, you should get XCode output similar to below.

```shell script
Basic[19446:10081868] Requested Camera Permission
...
Basic[19446:10081868] Head Tracking configured successfully.
Basic[19446:10081868] Metal API Validation Enabled
Basic[19446:10081868] Head Tracking enabled successfully.
```

* If you run on a simulator or device that does not support FaceID, you should get XCode output similar to below. `JabberwockyARKitEngine.xcframework` binary comes with i386 and x86_64 module archs, so that running in a simulator should not crash.

```
Basic[2476:18033900] Requested Camera Permission
Basic[2476:18033900] Head Tracking cannot be configured. It is not supported on this device.
Basic[2476:18033900] Head Tracking is not configured. Use HeadTracking.configure() to configure.
```

## Release Instructions (Swiftable Developers)

* [Release Instructions](RELEASE.md) for JabberwockyHTKit

## About
The Jabberwocky® Head Tracking Kit (`JabberwockyHTKit`) is an open-source iOS framework, developed by [Swiftable LLC](https://www.jabberwockyapp.com), that provides a touch-free interface for existing iOS applications. Jabberwocky enables users to interact with an application by just moving their head. Head movement translates into the movement of a mouse-like cursor on the screen. By default, blinks trigger a `.touchUpInside` event simulating a tap on any `UIControl` subclass (in fact any subclass of `UIView` can be extended to respond to a facial gesture trigger).

Jabberwocky was originally designed as an **accessibility tool** for users with mobility impairments such as ALS or Spinal Cord Injury (SCI) to enable effective and efficient interaction with iOS devices. Currently, Jabberwocky requires [ARKit](https://developer.apple.com/augmented-reality/arkit/) and is only supported on devices that also support [FaceID](https://support.apple.com/en-us/HT208108). Supported devices include:
* iPhone X and later models
* iPad Pro models with the A12X Bionic chip

As of iOS 13, Head Tracking Accessibility was added to [iOS Switch Control](https://support.apple.com/en-us/HT201370#usesc) for the same device models supported by Jabberwocky. It is important to note that iOS Head Tracking can be configured to operate in a similar capacity to Jabberwocky Head Tracking, but is provided at the OS level. While iOS Head Tracking Accessibility works across the entire device, its tight coupling with Switch Control, complicated setup, and limited feature set make it unsuitable for many users. Jabberwocky supports in-app customization of Head Tracking and provides custom event hooks.

## Applications
`JabberwockyHTKit` is currently being used by the following applications in the [App Store](https://apps.apple.com/):
* [Jabberwocky AAC](https://apps.apple.com/us/app/jabberwocky/id1438561966) - A touch-free text-to-speech app (Free).
* [Jabberwocky Browser](https://apps.apple.com/us/app/jabberwocky-browser/id1455137144) - A touch-free web browser (Free).

## Dependencies
`JabberwockyHTKit` does not require any non-[Apple Frameworks](https://developer.apple.com/documentation/) other than `JabberwockyARKitEngine`. While `JabberwockyHTKit` is open-source and licensed under the [Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0), it depends on `JabberwockyARKitEngine` which is closed-source and licensed under the [Permissive Binary License](https://www.mbed.com/en/licenses/permissive-binary-license/).  `JabberwockyARKitEngine` is free to redistribute in its [binary form](https://github.com/swiftablellc/jabberwocky-head-tracking-kit-ios/tree/master/JabberwockyARKitEngine.xcframework), without modification, provided the conditions of the license are met.

`JabberwockyHTKit` is available in the [Jabberwocky CocoaPods Spec Repo](https://github.com/swiftablellc/jabberwocky-specs-repo) and is also available in the [CocoaPods Trunk Repo](https://cocoapods.org/pods/JabberwockyHTKit).


## Trademarks
Jabberwocky® is a registered trademark of Swiftable LLC.

## License
[Apache 2.0 License](LICENSE)
