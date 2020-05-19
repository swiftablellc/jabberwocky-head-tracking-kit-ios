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

import CoreGraphics
import JabberwockyHTKitCore

/*
 In Memory Settings
 */
@objc public class InMemorySettings: DefaultSettings {
    
    private var objectStore: [String: Any] = [:]
    private var optionStore: [String: Any] = [:]
    
    override public func getObject(_ key: String) -> Any? {
        if let objectValue = objectStore[key] {
            return objectValue
        } else {
            return super.getObject(key)
        }
    }

    override public func getOption(_ key: String) -> Any? {
        if let optionValue = optionStore[key] {
            return optionValue
        } else {
            return super.getOption(key)
        }
    }

    @discardableResult
    override public func setObject(_ key: String, _ objectValue: Any) -> Bool {
        guard let optionSpec = optionSpecifications[key] else { return false }
        guard let optionValue = optionSpec.toOptionValue(objectValue: objectValue) else { return false}
        updateInMemory(key: key, objectValue: objectValue, optionValue: optionValue, optionSpec: optionSpec)
        return true
    }

    @discardableResult
    override public func setOption(_ key: String, _ optionValue: Any) -> Bool {
        guard let optionSpec = optionSpecifications[key] else { return false }
        guard let objectValue = optionSpec.toObjectValue(optionValue: optionValue) else { return false}
        updateInMemory(key: key, objectValue: objectValue, optionValue: optionValue, optionSpec: optionSpec)
        return true
    }
    
    internal func updateInMemory(key: String, objectValue: Any, optionValue: Any, optionSpec: HTSettingsOptionSpec) {
        objectStore[key] = objectValue
        optionStore[key] = optionValue
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .htOnHeadTrackingSettingsUpdateNotification, object: nil)
        }
    }
    
}
