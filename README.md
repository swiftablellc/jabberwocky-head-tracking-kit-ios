# Jabberwocky Head Tracking Kit for iOS
![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/swiftablellc/jabberwocky-head-tracking-kit-ios?label=release&sort=semver) ![Platform](https://img.shields.io/badge/platform-iOS-lightgrey) ![GitHub](https://img.shields.io/github/license/swiftablellc/jabberwocky-head-tracking-kit-ios) 

> Head Tracking Cursor for any iOS app!

![htkit-demo](https://user-images.githubusercontent.com/6625903/82473198-d5ba2080-9a8e-11ea-9c2a-379558bf8b65.gif)

## About
The Jabberwocky® Head Tracking Kit (`JabberwockyHTKit`) is an open-source iOS framework, developed by Swiftable LLC, that provides a touch-free interface for existing iOS applications. Jabberwocky enables users to interact with an application by just moving their head. Head movement translates into the movement of a mouse-like cursor on the screen. By default, blinks trigger a `.touchUpInside` event simulating a tap on any `UIControl` subclass (in fact any subclass of `UIView` can be extended to respond to a facial gesture trigger).

Jabberwocky was originally designed as an **accessibility tool** for users with mobility impairments such as ALS or Spinal Cord Injury (SCI) to enable effective and efficient interaction with iOS devices. Currently, Jabberwocky requires [ARKit](https://developer.apple.com/augmented-reality/arkit/) and is only supported on devices that also support [FaceID](https://support.apple.com/en-us/HT208108). Supported devices include:
* iPhone X and later models
* iPad Pro models with the A12X Bionic chip

As of iOS 13, Head Tracking Accessibility was added to [iOS Switch Control](https://support.apple.com/en-us/HT201370#usesc) for the same device models supported by Jabberwocky. It is important to note that iOS Head Tracking can be configured to operate in a similar capacity to Jabberwocky Head Tracking, but is provided at the OS level. While iOS Head Tracking Accessibility works across the entire device, its tight coupling with Switch Control, complicated setup, and limited feature set make it unsuitable for many users. Jabberwocky supports in-app customization of Head Tracking and provides custom event hooks.

## Add Head Tracking to an Existing Application

`BasicTutorial-PodsOnly` is an example application target that has one standard `UIButton` which responds to taps on the screen. When configuring head tracking within an existing application there are a few setup steps that need to be performed. Once `JabberwockyHTKit` is configured and enabled, the default `HTFeature` singletons that are configured will automatically detect `UIControl`, `UICollectionViewCell`, and `UITableViewCell` elements and interact with them. Other custom `UIView` elements can be configured to work with the head tracking framework by implementing the `HTFocusable` protocol (more info below).

### Step 1: Install JabberwockyHTKit Frameworks

* Create a `Podfile` and replace `$YOUR_TARGET` with the appropriate target:

```shell script
source 'https://github.com/swiftablellc/jabberwocky-specs-repo.git'
source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!
platform :ios, '12.0'

target '$YOUR_TARGET' do
  pod 'JabberwockyHTKit'
end
```

* Install dependencies using CocoaPods. Install [CocoaPods](https://guides.cocoapods.org/using/getting-started.html) if you haven't already:

```shell script
pod install
```
* Don't forget to open your project using the `*.xcworkspace` instead of  `.xcodeproj` or you will get a Pods not found error.

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
import JabberwockyHTKit

...

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AVCaptureDevice.requestAccess(for: .video) { (granted) in
            if (granted) {
                // Configure the default HTFeatures and enable Head Tracking
                DispatchQueue.main.async {
                    HeadTracking.configure()
                    HeadTracking.shared.enable()
                }
            } else {
                NSLog("Camera Permissions Missing for Head Tracking.")
            }
        }
        return true
    }
```
#### [SwiftUI](https://developer.apple.com/xcode/swiftui/)

* SwiftUI is only partially supported (introspection and programmatic triggering of events in SwiftUI is elusive at this point). For an example implementation, which is very similar to pre-iOS 13 Swift is available at [SwiftUI Tutorial SceneDelegate](Tutorials/SwiftUITutorial/SceneDelegate.swift). The `UIWindowScene` needs to be provided to the Jabberwocky `HeadTracking` singleton for Jabberwocky to manage `UIWindow` stacks properly.

```swift
import AVFoundation
import JabberwockyHTKit

...

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        if let windowScene = scene as? UIWindowScene {
            HeadTracking.ifConfiguredElse(configuredCompletion: { ht in
                ht.windowScene = windowScene
                ht.enable()
            }) {
                AVCaptureDevice.requestAccess(for: .video) { (granted) in
                    if (granted) {
                        // Configure the default HTFeatures and enable Head Tracking
                        DispatchQueue.main.async {
                            HeadTracking.configure()
                            HeadTracking.shared.windowScene = windowScene
                            HeadTracking.shared.enable()
                        }
                    } else {
                        NSLog("Head Tracking requires camera access.")
                    }
                }
            }
        }
    }
```

#### Objective C

* See [Objc Tutorial AppDelegate](Tutorials/ObjcTutorial/AppDelegate.m) for example implementation.

```objc
#import <AVFoundation/AVFoundation.h>
#import "JabberwockyHTKit.h"

...

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        NSLog(@"Requested Camera Permission");
        if(granted){
            dispatch_async(dispatch_get_main_queue(), ^{
                [HeadTracking configureWithFeatures:HeadTracking.DEFAULT_FEATURES withSettingsAppGroup:nil];
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

* If you run on a simulator or device that does not support FaceID, you should get XCode output similar to below. `JabberwockyHTKitCore.framework` binary comes with i386 and x86_64 module archs, so that running in a simulator should not crash.

```
Basic[2476:18033900] Requested Camera Permission
Basic[2476:18033900] Head Tracking cannot be configured. It is not supported on this device.
Basic[2476:18033900] Head Tracking is not configured. Use HeadTracking.configure() to configure.
```

## Build JabberwockyHTKit from Source

To build and run `JabberwockyHTKit` from source follow the steps below.  

### Step 1: Checkout and Install Dependencies

* Check out from source:

```shell script
git clone git@github.com:swiftablellc/jabberwocky-head-tracking-kit-ios.git && cd jabberwocky-head-tracking-kit-ios.git
```

* Install dependencies using CocoaPods. Install [CocoaPods](https://guides.cocoapods.org/using/getting-started.html) if you haven't already:

```shell script
pod install
```

### Step 2: Build Framework

* Open XCode using the `JabberwockyHTKit.xcworkspace` that was just generated by Cocoapods. *If you open using `.xcodeproj` you will get an error!*
* Select the `JabberwockyHTKit` scheme and any Device/Simulator and then run in XCode.

### Step 3: Run Tutorial

* Open XCode using the `JabberwockyHTKit.xcworkspace` that was just generated by Cocoapods. *If you open using `.xcodeproj` you will get an error!*
* Select the `BasicTutorial` scheme and run on a `FaceID` enabled device.
    * This uses the pod install of `JabberwockyHTKitCore` but uses the local build of `JabberwockyHTKit` from source.

### Notes

* `*-LocalDev` schemes are for development of `JabberwockyHTKit` and `JabberwockyHTKitCore` simultaneously. This is not a common use case, so it is safe to ignore these schemes.
* `*-PodsOnly` schemes pull all dependencies from CocoaPods and therefore are not very useful for local development of `JabberwockyHTKit`.
* `JabberwockyHTKit` uses CocoaPods to install its one dependency `JabberwockyHTKitCore`, but the `JabberwockyHTKitCore.framework` can be found [here](https://github.com/swiftablellc/jabberwocky-head-tracking-kit-core-ios-binary/tree/master/JabberwockyHTKitCore.framework). If you don't want to use CocoaPods you checkout the repository with the framework binary and add it to the project. It might be best to create a new target similar to `JabberwockyHTKit-LocalDev` to get it to build properly.

## Release (Swiftable Devs Only)

1. Navigate to jabberwocky-head-tracking-kit-ios-binary directory
    * `git pull`
2. Update the JabberwockyHTKit.podspec file.
    * Modify the version number in spec.version.
    * Modify the swift_version if needed in spec.swift_version.
3. Prepare Release Commit
    * `git add *` 
    * `git commit -m 'Preparing <version> for release.'`
4. Tag version
    * `git tag -a <version> -m 'Tagging Release Version <version>'`
    * `git push origin --tags`
5. Do a pod spec lint from the version directory
    * `pod spec lint --verbose --sources="https://github.com/swiftablellc/jabberwocky-specs-repo.git" JabberwockyHTKit.podspec`
6. Upload to the `jabberwocky-specs-repo` Pods Repo
    * `pod repo push jabberwocky-specs-repo JabberwockyHTKit.podspec`
    * If you don't have the repo installed yet: `pod repo add jabberwocky-specs-repo https://github.com/swiftablellc/jabberwocky-specs-repo.git`
7. **IMPORTANT** - Finish pushing the commit to master.
    * `git push origin master`
    * We don't do this before, because we can amend the commit until the podspec lint succeeds.

## Applications
`JabberwockyHTKit` is currently being used by the following applications in the [App Store](https://apps.apple.com/):
* [Jabberwocky AAC](https://apps.apple.com/us/app/jabberwocky/id1438561966) - A touch-free text-to-speech app (Free).
* [Jabberwocky Browser](https://apps.apple.com/us/app/jabberwocky-browser/id1455137144) - A touch-free web browser (Free).

## Dependencies
`JabberwockyHTKit` does not require any non-[Apple Frameworks](https://developer.apple.com/documentation/) other than `JabberwockyHTKitCore`. While `JabberwockyHTKit` is open-source and licensed under the [Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0), it depends on `JabberwockyHTKitCore` which is closed-source and licensed under the [Permissive Binary License](https://www.mbed.com/en/licenses/permissive-binary-license/). `JabberwockyHTKitCore` is free to redistribute in its [binary form](https://github.com/swiftablellc/jabberwocky-head-tracking-kit-core-ios-binary/tree/master/JabberwockyHTKitCore.framework), without modification, provided the conditions of the license are met.

Both `JabberwockyHTKit` and `JabberwockyHTKitCore` are available in the [Jabberwocky CocoaPods Spec Repo](https://github.com/swiftablellc/jabberwocky-specs-repo) and may be pushed to the master CocoaPods repo in the future.


## Trademarks
Jabberwocky® is a registered trademark of Swiftable LLC.

## License
[Apache 2.0 License](LICENSE)
