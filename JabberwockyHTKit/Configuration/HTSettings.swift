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
    
    var appName: String {get set}

    var clickGesture: ClickGestureOption {get set}
    var cursorGraphicsMode: CursorGraphicsMode {get set}
    var disableCursorToggle: Bool {get set}
    var disabledByUser: Bool {get set}
    var dwellTime: CFTimeInterval {get set}
    var minimumElementSize: CGFloat {get set}
    var shareSensitivity: Bool {get set}
    
}

@objc public enum ClickGestureOption: Int, RawRepresentable {
    case Blink // Default
    case Dwell
    
    public typealias RawValue = String
    
    public var rawValue: RawValue {
        switch self {
        case .Blink: return "Blink"
        case .Dwell: return "Dwell"
        }
    }
    
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "Blink": self = .Blink
        case "Dwell": self = .Dwell
        default: return nil
        }
    }
}

//0.2 is probably as low as you would ever wanna go, to reach the edges and not lose camera.
//0.5 is probably good for high. 1.0 is the highest where I could even hope to control it.
//0.3 is splitting the difference.
@objc public enum CursorSensitivityOption: Int, RawRepresentable {
    case Low
    case Medium
    case High
    case Highest
    
    public typealias RawValue = Float
    
    public var rawValue: RawValue {
        switch self {
        case .Low: return 0.2
        case .Medium: return 0.3
        case .High: return 0.5
        case .Highest: return 0.7
        }
    }
    
    public init?(rawValue: RawValue) {
        switch rawValue {
        case 0.2: self = .Low
        case 0.3: self = .Medium
        case 0.5: self = .High
        case 0.7: self = .Highest
        default: return nil
        }
    }
    
}

//At 0.12 I still get an unintentional blink every once in a while. Some other people seem to as well.
//But I have seen a couple people who would probably have liked something more sensitive than me...
@objc public enum BlinkSensitivityOption: Int, RawRepresentable {
    case Highest
    case High
    case Medium
    case Low
    
    public typealias RawValue = CFTimeInterval
    
    public var rawValue: RawValue {
        switch self {
        case .Highest: return 0.0
        case .High: return 0.12
        case .Medium: return 0.19
        case .Low: return 0.29
        }
    }
    
    public init?(rawValue: RawValue) {
        switch rawValue {
        case 0.0: self = .Highest
        case 0.12: self = .High
        case 0.19: self = .Medium
        case 0.29: self = .Low
        default: return nil
        }
    }
}

@objc public enum CursorGraphicsMode: Int, RawRepresentable {
    case Highlight
    case Classic
    
    public typealias RawValue = String
    
    public var rawValue: RawValue {
        switch self {
        case .Highlight: return "Highlight"
        case .Classic: return "Classic"
        }
    }
    
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "Highlight": self = .Highlight
        case "Classic": self = .Classic
        default: return nil
        }
    }
}

@objc public enum CursorToggle: Int, RawRepresentable {
    case click
    case scroll
    
    public typealias RawValue = String
    
    public var rawValue: RawValue {
        switch self {
        case .click: return "Click"
        case .scroll: return "Scroll"
        }
    }
    
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "Click": self = .click
        case "Scroll": self = .scroll
        default: return nil
        }
    }
}

@objc public enum DwellTimeOption: Int, RawRepresentable {
    //0.75 is probably as low as you would wanna go
    //1.5 seems to be a good default
    //2.25 for symmetry on the other side
    case Fast
    case Medium
    case Slow
    
    public typealias RawValue = CFTimeInterval
    
    public var rawValue: RawValue {
        switch self {
        case .Fast: return 0.75
        case .Medium: return 1.5
        case .Slow: return 2.25
        }
    }
    
    public init?(rawValue: RawValue) {
        switch rawValue {
        case 0.75: self = .Fast
        case 1.5: self = .Medium
        case 2.25: self = .Slow
        default: return nil
        }
    }
}
