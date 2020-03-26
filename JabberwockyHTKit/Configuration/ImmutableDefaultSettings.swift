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

@objc class ImmutableDefaultSettings: NSObject, HTSettings {
    
    override init() { }
    
    var appName: String {
        get {
            return Bundle.main.infoDictionary!["CFBundleName"] as? String ?? ""
        } set { }
    }

    var disabledByUser: Bool {
        get {
            return false
        } set { }
    }

    var clickGesture: ClickGestureOption {
        get {
            return .Blink
        } set { }
    }

    var cursorGraphicsMode: CursorGraphicsMode {
        get {
            return .Highlight
        } set { }
    }
    
    var disableCursorToggle: Bool {
        get {
            return false
        } set { }
    }

    var horizontalSensitivity: Float {
        get {
            return CursorSensitivityOption.Medium.rawValue
        } set { }
    }

    var verticalSensitivity: Float {
        get {
            return CursorSensitivityOption.Medium.rawValue
        } set { }
    }

    var shareSensitivity: Bool {
        get {
            return true
        } set { }
    }

    var blinkSensitivity: CFTimeInterval {
        get {
            return BlinkSensitivityOption.Highest.rawValue
        } set { }
    }

    var minimumElementSize: CGFloat {
        get {
            return HTLayout.defaultButtonSize
        } set { }
    }

    var dwellTime: CFTimeInterval {
        get {
            return DwellTimeOption.Medium.rawValue
        } set { }
    }
    
    var headMovementCorrection: HeadMovementCorrection {
        get {
            return HeadMovementCorrection(.Low)
        } set { }
    }
}
