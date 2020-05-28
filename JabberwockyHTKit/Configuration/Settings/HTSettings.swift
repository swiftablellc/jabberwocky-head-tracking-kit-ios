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

@objc public protocol HTSettings: HTCoreSettings {

    // MARK: Convenience Methods
    var blinkSensitivity: CFTimeInterval {get set}
    var clickGesture: ClickGesture {get set}
    var cursorGraphicsMode: CursorGraphicsMode {get set}
    var disabledByUser: Bool {get set}
    var dwellTime: CFTimeInterval {get set}
    var minimumElementSize: CGFloat {get set}
    var shareSpeed: Bool {get set}

    // MARK: Generic Getters/Setters
    func getDefaultObject(_ key: String) -> Any?
    func getDefaultOption(_ key: String) -> Any?
    func getObject(_ key: String) -> Any?
    func getOption(_ key: String) -> Any?
    func getObjects() -> [String: Any]
    func getOptions() -> [String: Any]
    
    @discardableResult func setObject(_ key: String, _ objectValue: Any) -> Bool
    @discardableResult func setOption(_ key: String, _ optionValue: Any) -> Bool
    
}

public extension HTSettings {
    
    func getTypedObject<O: HTSettingsOptionSpecTyped>(_ optionSpec: O) -> O.ObjectType {
        if let objectValue = self.getObject(optionSpec.key) as? O.ObjectType {
            return objectValue
        }
        return optionSpec.defaultObjectValueTyped
    }

}

public protocol HTSettingsOptionSpec {
    var key: String {get}
    var defaultObjectValue: Any {get}
    
    func toObjectValue(optionValue: Any) -> Any?
    func toOptionValue(objectValue: Any) -> Any?
}

public protocol HTSettingsOptionSpecTyped: HTSettingsOptionSpec {
    
    associatedtype ObjectType
    associatedtype OptionType
    
    var defaultObjectValueTyped: ObjectType {get}
    
    func toObjectValueTyped(optionValue: OptionType) -> ObjectType?
    func toOptionValueTyped(objectValue: ObjectType) -> OptionType?
}

public extension HTSettingsOptionSpecTyped {
    
    var defaultObjectValue: Any {
        return defaultObjectValueTyped
    }
    
    func toObjectValue(optionValue: Any) -> Any? {
        if let optionValue = optionValue as? OptionType {
            return toObjectValueTyped(optionValue: optionValue)
        }
        return nil
    }
    
    func toOptionValue(objectValue: Any) -> Any? {
        if let objectValue = objectValue as? ObjectType {
            return toOptionValueTyped(objectValue: objectValue)
        }
        return nil
    }
}
