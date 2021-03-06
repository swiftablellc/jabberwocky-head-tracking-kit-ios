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

 
public class ClickGestureOption: HTSettingsOptionSpecTyped {

    public typealias ObjectType = ClickGesture
    public typealias OptionType = String
    
    private init() {}
    public static let shared = ClickGestureOption()
    
    public var key = "clickGesture"
    public var defaultObjectValueTyped = ClickGesture.Blink
    
    public func toObjectValueTyped(optionValue: String) -> ClickGesture? {
        return ClickGesture(rawValue: optionValue)
    }
    
    public func toOptionValueTyped(objectValue: ClickGesture) -> String? {
        return objectValue.rawValue
    }

}

@objc public enum ClickGesture: Int, RawRepresentable {
    case Blink
    case Dwell
    
    public typealias RawValue = String
    
    public var rawValue: RawValue {
        switch self {
            case .Blink: return "Blink"
            case .Dwell: return "Dwell"
        }
    }
    
    public init?(rawValue: RawValue) {
        switch rawValue.lowercased() {
            case ClickGesture.Blink.rawValue.lowercased(): self = .Blink
            case ClickGesture.Dwell.rawValue.lowercased(): self = .Dwell
            default: return nil
        }
    }

}
