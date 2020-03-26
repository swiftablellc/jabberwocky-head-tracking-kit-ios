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

@objc class InMemorySettings: NSObject, HTSettings {
    
    private let defaultSettings = ImmutableDefaultSettings()
    
    private var _isHeadTrackingDisabled: Bool?
    private var _clickGesture: ClickGestureOption?
    private var _cursorGraphicsMode: CursorGraphicsMode?
    private var _disableCursorToggle: Bool?
    private var _horizontalSensitivity: Float?
    private var _verticalSensitivity: Float?
    private var _shareSensitivity: Bool?
    private var _blinkSensitivity: CFTimeInterval?
    private var _dwellTime: CFTimeInterval?
    private var _headMovementCorrection: HeadMovementCorrection?
    
    override init() { }
    
    var appName: String {
        get {
            return defaultSettings.appName
        } set { }
    }

    var disabledByUser: Bool {
        get {
            if _isHeadTrackingDisabled == nil {
                _isHeadTrackingDisabled = defaultSettings.disabledByUser
            }
            return _isHeadTrackingDisabled!
        } set {
            _isHeadTrackingDisabled = newValue
            // Always send a notification of a potential change in the status of head tracking
            // This has to be in a dispatch queue because otherwise it causes a simultaneous access exception
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .htOnHeadTrackingStatusUpdateNotification, object: nil)
            }
        }
    }

    var clickGesture: ClickGestureOption {
        get {
            if _clickGesture == nil {
                _clickGesture = defaultSettings.clickGesture
            }
            return _clickGesture!
        } set {
            _clickGesture = newValue
        }
    }

    var cursorGraphicsMode: CursorGraphicsMode {
        get {
            if _cursorGraphicsMode == nil {
                _cursorGraphicsMode = defaultSettings.cursorGraphicsMode
            }
            return _cursorGraphicsMode!
        } set {
            _cursorGraphicsMode = newValue
        }
    }
    
    var disableCursorToggle: Bool {
        get {
            if _disableCursorToggle == nil {
                _disableCursorToggle = defaultSettings.disableCursorToggle
            }
            return _disableCursorToggle!
        } set {
            _disableCursorToggle = newValue
        }
    }

    var horizontalSensitivity: Float {
        get {
            if _horizontalSensitivity == nil {
                _horizontalSensitivity = defaultSettings.horizontalSensitivity
            }
            return _horizontalSensitivity!
        } set {
            _horizontalSensitivity = newValue
        }
    }

    var verticalSensitivity: Float {
        get {
            if _verticalSensitivity == nil {
                _verticalSensitivity = defaultSettings.verticalSensitivity
            }
            return _verticalSensitivity!
        } set {
            _verticalSensitivity = newValue
        }
    }

    var shareSensitivity: Bool {
        get {
            if _shareSensitivity == nil {
                _shareSensitivity = defaultSettings.shareSensitivity
            }
            return _shareSensitivity!
        } set {
            _shareSensitivity = newValue
        }
    }

    var blinkSensitivity: CFTimeInterval {
        get {
            if _blinkSensitivity == nil {
                _blinkSensitivity = defaultSettings.blinkSensitivity
            }
            return _blinkSensitivity!
        } set {
            _blinkSensitivity = newValue
        }
    }

    // TODO: Make minimum element size configurable
    var minimumElementSize: CGFloat {
        get {
            return defaultSettings.minimumElementSize
        } set { }
    }

    var dwellTime: CFTimeInterval {
        get {
            if _dwellTime == nil {
                _dwellTime = defaultSettings.dwellTime
            }
            return _dwellTime!
        } set {
            _dwellTime = newValue
        }
    }
    
    var headMovementCorrection: HeadMovementCorrection {
        get {
            if _headMovementCorrection == nil {
                _headMovementCorrection = defaultSettings.headMovementCorrection
            }
            return _headMovementCorrection!
        } set {
            _headMovementCorrection = newValue
        }
    }
}
