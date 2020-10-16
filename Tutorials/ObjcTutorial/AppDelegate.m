/*
Copyright 2020 Swiftable, LLC. <contact@swiftable.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

#import <AVFoundation/AVFoundation.h>
#import "JabberwockyARKitEngine.h"
#import "JabberwockyHTKit.h"
#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        NSLog(@"Requested Camera Permission");
        if(granted) {
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

@end


