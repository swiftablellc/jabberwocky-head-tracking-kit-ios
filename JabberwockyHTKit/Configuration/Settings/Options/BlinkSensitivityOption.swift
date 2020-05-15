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

 
public class BlinkSensitivityOption: HTSettingsOptionSpecTyped {
    
    public typealias ObjectType = CFTimeInterval
    public typealias OptionType = String
    
    private init() {}
    public static let shared = BlinkSensitivityOption()
    
    public var key = "blinkSensitivity"
    public var defaultObjectValueTyped = Transform.Highest.rawValue

    public var valueChangedClosure: () -> Void = { }
    
    public func toObjectValueTyped(optionValue: String) -> CFTimeInterval? {
        return Transform.fromLabel(optionValue)?.rawValue
    }
    
    public func toOptionValueTyped(objectValue: CFTimeInterval) -> String? {
        return Transform(objectValue)?.label
    }
    
    /*
     At 0.12 I still get an unintentional blink every once in a while. Some other people seem to as well.
     But I have seen a couple people who would probably have liked something more sensitive than me...
     */
    public enum Transform: CFTimeInterval, CaseIterable {
        case Highest = 0.0
        case High = 0.12
        case Medium = 0.19
        case Low = 0.29
        
        var label: String {
            return String(describing: self)
        }
        
        public init?(_ rawValue: CFTimeInterval) {
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
