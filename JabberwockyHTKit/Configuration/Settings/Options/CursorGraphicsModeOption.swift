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

 
public class CursorGraphicsModeOption: HTSettingsOptionSpecTyped {
    
    public typealias ObjectType = CursorGraphicsMode
    public typealias OptionType = String
    
    private init() {}
    public static let shared = CursorGraphicsModeOption()
    
    public var key = "cursorGraphicsMode"
    public var defaultObjectValueTyped = CursorGraphicsMode.Highlight
    
    public func toObjectValueTyped(optionValue: String) -> CursorGraphicsMode? {
        return CursorGraphicsMode(rawValue: optionValue)
    }
    
    public func toOptionValueTyped(objectValue: CursorGraphicsMode) -> String? {
        return objectValue.rawValue
    }

}

@objc public enum CursorGraphicsMode: Int, RawRepresentable {
    case Classic
    case Highlight
    
    public typealias RawValue = String
    
    public var rawValue: RawValue {
        switch self {
            case .Classic: return "Classic"
            case .Highlight: return "Highlight"
        }
    }
    
    public init?(rawValue: String) {
        switch rawValue.lowercased() {
            case CursorGraphicsMode.Classic.rawValue.lowercased(): self = .Classic
            case CursorGraphicsMode.Highlight.rawValue.lowercased(): self = .Highlight
            default: return nil
        }
    }
}
