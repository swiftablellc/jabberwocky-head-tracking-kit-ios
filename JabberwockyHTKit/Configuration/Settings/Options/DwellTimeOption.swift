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

 
public class DwellTimeOption: HTSettingsOptionSpecTyped {
    
    public typealias ObjectType = CFTimeInterval
    public typealias OptionType = String
    
    private init() {}
    public static let shared = DwellTimeOption()
    
    public var key = "dwellTime"
    public var defaultObjectValueTyped = Transform.Medium.rawValue
    public var valueChangedClosure: () -> Void = { }
    
    public func toObjectValueTyped(optionValue: String) -> CFTimeInterval? {
        return Transform.fromLabel(optionValue)?.rawValue
    }
    
    public func toOptionValueTyped(objectValue: CFTimeInterval) -> String? {
        return Transform(objectValue)?.label
    }
    
    
    /*
     0.75 is probably as low as you would wanna go
     1.5 seems to be a good default
     2.25 for symmetry on the other side
     */
    public enum Transform: CFTimeInterval, CaseIterable {
        case Fast = 0.75
        case Medium = 1.5
        case Slow = 2.25
        
        var label: String {
            return String(describing: self)
        }
        
        public init?(_ rawValue: CFTimeInterval) {
            switch rawValue {
                case Transform.Fast.rawValue: self = .Fast
                case Transform.Medium.rawValue: self = .Medium
                case Transform.Slow.rawValue: self = .Slow
                default: return nil
            }
        }
        
        public static func fromLabel(_ label: String) -> Transform? {
            return self.allCases.first{ "\($0)".caseInsensitiveCompare(label) == .orderedSame }
        }
    }
}
