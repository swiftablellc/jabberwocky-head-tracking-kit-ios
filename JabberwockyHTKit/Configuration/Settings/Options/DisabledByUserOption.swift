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

 
public class DisabledByUserOption: HTSettingsOptionSpecTyped {
    
    public typealias ObjectType = Bool
    public typealias OptionType = Bool
    
    private init() {}
    public static let shared = DisabledByUserOption()
    
    public var key = "disabledByUser"
    public var defaultObjectValueTyped = false
    public var valueChangedClosure: () -> Void = {
        // Always send a notification of a potential change in the status of head tracking
        // Always use the main dispatch queue for these notifications!
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .htOnHeadTrackingStatusUpdateNotification, object: nil)
        }
    }
    
    public func toObjectValueTyped(optionValue: Bool) -> Bool? {
        return optionValue
    }
    
    public func toOptionValueTyped(objectValue: Bool) -> Bool? {
        return objectValue
    }
}
