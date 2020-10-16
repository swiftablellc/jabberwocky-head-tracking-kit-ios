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

extension NSNotification {
    @objc public static let htActivationContextKey: String = "HTNotificationActivationContextObjectKey"
    @objc public static let htBlinkContextKey: String = "HTNotificationBlinkContextObjectKey"
    @objc public static let htCursorContextKey: String = "HTNotificationCursorContextObjectKey"
    
    @objc public static let htActivationNotificationKey = "htActivationNotification"
    @objc public static let htOnBlinkNotificationKey = "htOnBlinkNotification"
    @objc public static let htOnCursorUpdateNotificationKey = "htOnCursorUpdateNotification"
    @objc public static let htOnHeadShakeNotificationKey = "htOnHeadShakeNotification"
    @objc public static let htOnRecalibrateNotificationKey = "htOnRecalibrateInitiatedNotification"
}

extension NSNotification.Name {

    public static let htActivationNotification = NSNotification.Name(NSNotification.htActivationContextKey)
    public static let htOnBlinkNotification = NSNotification.Name(NSNotification.htOnBlinkNotificationKey)
    public static let htOnCursorUpdateNotification = NSNotification.Name(NSNotification.htOnCursorUpdateNotificationKey)
    public static let htOnHeadShakeNotification = NSNotification.Name(NSNotification.htOnHeadShakeNotificationKey)
    public static let htOnRecalibrateNotification = NSNotification.Name(NSNotification.htOnRecalibrateNotificationKey)

}
