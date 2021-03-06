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


public class HorizontalSpeedOption: CursorSpeedOption {
    
    private override init() {}
    public static let shared = HorizontalSpeedOption()
    
    public override var key: String {
        return "horizontalSpeed"
    }
}

public class VerticalSpeedOption: CursorSpeedOption {
    
    private override init() {}
    public static let shared = VerticalSpeedOption()
    
    public override var key: String {
        return "verticalSpeed"
    }
}

public class CursorSpeedOption: HTSettingsOptionSpecTyped {

    public typealias ObjectType = Float
    public typealias OptionType = String
    
    public var key: String {
        return  "cursorSpeed"
    }
    public var defaultObjectValueTyped = Transform.Medium.rawValue
    
    public func toObjectValueTyped(optionValue: String) -> Float? {
        return Transform.fromLabel(optionValue)?.rawValue
    }
    
    public func toOptionValueTyped(objectValue: Float) -> String? {
        return Transform(objectValue)?.label
    }
    
    public enum Transform: Float, CaseIterable {
        case Highest = 1.0
        case High = 0.7
        case Medium = 0.3
        case Low = 0.0
        
        var label: String {
            return String(describing: self)
        }
        
        public init?(_ rawValue: Float) {
            switch rawValue {
                case Transform.Highest.rawValue: self = .Highest
                case Transform.High.rawValue: self = .High
                case Transform.Medium.rawValue: self = .Medium
                case Transform.Low.rawValue: self = .Low
                default: return nil
            }
        }
        
        public static func fromLabel(_ label: String) -> Transform? {
            return self.allCases.first{ "\($0)".caseInsensitiveCompare(label) == .orderedSame }
        }
    }
}
