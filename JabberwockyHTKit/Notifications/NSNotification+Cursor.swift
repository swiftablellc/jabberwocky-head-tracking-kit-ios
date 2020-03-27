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

import Foundation

extension NSNotification {

    @objc public static let htCursorModeKey: String = "HTNotificationCursorModeObjectKey"
    @objc public static let htFocusedElementKey: String = "HTNotificationFocusedElementObjectKey"
    
    @objc public static let htOnChangeCursorModeNotificationKey = "htOnChangeCursorModeNotification"
    @objc public static let htOnCursorFocusNotificationKey = "htOnCursorFocusNotification"
    @objc public static let htOnCursorModeUpdateNotificationKey = "htOnCursorModeUpdateNotification"
    @objc public static let htOnCursorClickNotificationKey = "htOnCursorClickNotification"
    
    @objc public static let htInitiateRecalibrationCountdownNotification = "htInitiateRecalibrationCountdownNotification"
    @objc public static let htOnHeadTrackingStatusUpdateNotificationKey = "htOnHeadTrackingStatusUpdateNotification"
    
}

extension NSNotification.Name {
    public static let htOnChangeCursorModeNotification =
        NSNotification.Name(NSNotification.htOnChangeCursorModeNotificationKey)
    public static let htOnCursorFocusNotification =
        NSNotification.Name(NSNotification.htOnCursorFocusNotificationKey)
    public static let htOnCursorModeUpdateNotification =
        NSNotification.Name(NSNotification.htOnCursorModeUpdateNotificationKey)
    public static let htOnCursorClickNotification =
        Notification.Name(NSNotification.htOnCursorClickNotificationKey)

    public static let htInitiateRecalibrationCountdownNotification = Notification.Name(NSNotification.htInitiateRecalibrationCountdownNotification)
    public static let htOnHeadTrackingStatusUpdateNotification = Notification.Name(NSNotification.htOnHeadTrackingStatusUpdateNotificationKey)
}
