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
 
public class CursorStickinessOption: HTSettingsOptionSpecTyped {
    
    public typealias ObjectType = Float
    public typealias OptionType = String
    
    private init() {}
    public static let shared = CursorStickinessOption()
    
    public var key = "cursorStickiness"
    public var defaultObjectValueTyped: Float = 0.0
    
    public func toObjectValueTyped(optionValue: String) -> Float? {
        return Transform.fromLabel(optionValue)?.rawValue
    }
    
    public func toOptionValueTyped(objectValue: Float) -> String? {
        return Transform(objectValue)?.label
    }
    
    public enum Transform: Float, CaseIterable {
        case High = 1.0
        case Medium = 0.5
        case Low = 0.0
        
        var label: String {
            return String(describing: self)
        }
        
        public init?(_ rawValue: Float) {
            switch rawValue {
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
