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

class StoredSettings: NSObject, HTSettings {
    
    @objc public static let KEY_PREFIX = "Jabberwocky/"
    @objc public static let DISABLED_BY_USER_KEY = StoredSettings.KEY_PREFIX + "disabledByUser"
    @objc public static let CLICK_GESTURE_KEY = StoredSettings.KEY_PREFIX + "clickGesture"
    @objc public static let CURSOR_GRAPHICS_MODE_KEY = StoredSettings.KEY_PREFIX + "cursorGraphicsMode"
    @objc public static let DISABLE_CURSOR_TOGGLE_KEY = StoredSettings.KEY_PREFIX + "disableCursorToggle"
    
    @objc public static let HORIZONTAL_SENSITIVITY_KEY = StoredSettings.KEY_PREFIX + "horizontalSensitivity"
    @objc public static let VERTICAL_SENSITIVITY_KEY = StoredSettings.KEY_PREFIX + "verticalSensitivity"
    @objc public static let SHARE_SENSITIVITY_KEY = StoredSettings.KEY_PREFIX + "shareSensitivity"
    
    @objc public static let BLINKS_SENSITIVITY_KEY = StoredSettings.KEY_PREFIX + "blinkSensitivity"

    @objc public static let DWELL_TIME_KEY = StoredSettings.KEY_PREFIX + "dwellTime"
    
    @objc public static let HEAD_MOVEMENT_CORRECTION_KEY = StoredSettings.KEY_PREFIX + "headMovementCorrection"
    
    @objc public private(set) var appGroup: String?
    private var userDefaults: UserDefaults!
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
    
    init(appGroup: String) {
        self.appGroup = appGroup
        self.userDefaults = UserDefaults(suiteName: appGroup)
    }

    var appName: String {
        get {
            return defaultSettings.appName
        } set { }
    }
    
    var disabledByUser: Bool {
        get {
            if _isHeadTrackingDisabled == nil {
                _isHeadTrackingDisabled = userDefaults.bool(forKey: StoredSettings.DISABLED_BY_USER_KEY)
            }
            return _isHeadTrackingDisabled!
        }
        set{
            _isHeadTrackingDisabled = newValue
            userDefaults.setValue(_isHeadTrackingDisabled, forKeyPath: StoredSettings.DISABLED_BY_USER_KEY)
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
                let clickGestureString = userDefaults.string(forKey: StoredSettings.CLICK_GESTURE_KEY)
                switch (clickGestureString) {
                case ClickGestureOption.Dwell.rawValue:
                    _clickGesture = .Dwell
                case ClickGestureOption.Blink.rawValue:
                    _clickGesture = .Blink
                default:
                    _clickGesture = defaultSettings.clickGesture
                    userDefaults.setValue(
                        defaultSettings.clickGesture.rawValue,
                        forKeyPath: StoredSettings.CLICK_GESTURE_KEY)
                }
            }
            return _clickGesture!
        }
        set {
            _clickGesture = newValue
            userDefaults.set(_clickGesture!.rawValue, forKey: StoredSettings.CLICK_GESTURE_KEY)
        }
    }
    
    var cursorGraphicsMode: CursorGraphicsMode {
        get {
            if _cursorGraphicsMode == nil {
                let cursorGraphicsModeString = userDefaults.string(forKey: StoredSettings.CURSOR_GRAPHICS_MODE_KEY)
                switch (cursorGraphicsModeString) {
                case CursorGraphicsMode.Classic.rawValue:
                    _cursorGraphicsMode = .Classic
                case CursorGraphicsMode.Highlight.rawValue:
                    _cursorGraphicsMode = .Highlight
                default:
                    _cursorGraphicsMode = defaultSettings.cursorGraphicsMode
                    userDefaults.setValue(
                        defaultSettings.cursorGraphicsMode.rawValue,
                        forKeyPath: StoredSettings.CURSOR_GRAPHICS_MODE_KEY)
                }
            }
            return _cursorGraphicsMode!
        }
        set {
            _cursorGraphicsMode = newValue
            userDefaults.set(_cursorGraphicsMode!.rawValue, forKey: StoredSettings.CURSOR_GRAPHICS_MODE_KEY)
        }
    }
    
    var disableCursorToggle: Bool {
        get {
            if _disableCursorToggle == nil {
                if userDefaults.object(forKey: StoredSettings.DISABLE_CURSOR_TOGGLE_KEY) != nil {
                    _disableCursorToggle = userDefaults.bool(forKey: StoredSettings.DISABLE_CURSOR_TOGGLE_KEY)
                } else {
                    _disableCursorToggle = defaultSettings.disableCursorToggle
                    userDefaults.setValue(
                        defaultSettings.disableCursorToggle,
                        forKeyPath: StoredSettings.DISABLE_CURSOR_TOGGLE_KEY)
                }
            }
            return _disableCursorToggle!
        }
        set {
            _disableCursorToggle = newValue
            userDefaults.setValue(_disableCursorToggle, forKeyPath: StoredSettings.DISABLE_CURSOR_TOGGLE_KEY)
        }
    }
    
    var horizontalSensitivity: Float {
        get {
            if _horizontalSensitivity == nil {
                if userDefaults.object(forKey: StoredSettings.HORIZONTAL_SENSITIVITY_KEY) != nil {
                    _horizontalSensitivity = userDefaults.float(forKey: StoredSettings.HORIZONTAL_SENSITIVITY_KEY)
                } else {
                    _horizontalSensitivity = defaultSettings.horizontalSensitivity
                    userDefaults.setValue(
                        defaultSettings.horizontalSensitivity,
                        forKeyPath: StoredSettings.HORIZONTAL_SENSITIVITY_KEY)
                }
            }
            return _horizontalSensitivity!
        }
        set{
            _horizontalSensitivity = newValue
            userDefaults.setValue(_horizontalSensitivity, forKeyPath: StoredSettings.HORIZONTAL_SENSITIVITY_KEY)
        }
    }
    
    var verticalSensitivity: Float {
        get {
            if _verticalSensitivity == nil {
                if userDefaults.object(forKey: StoredSettings.VERTICAL_SENSITIVITY_KEY) != nil {
                    _verticalSensitivity = userDefaults.float(forKey: StoredSettings.VERTICAL_SENSITIVITY_KEY)
                } else {
                    _verticalSensitivity = defaultSettings.verticalSensitivity
                    userDefaults.setValue(
                        defaultSettings.verticalSensitivity,
                        forKeyPath: StoredSettings.VERTICAL_SENSITIVITY_KEY)
                }
            }
            return _verticalSensitivity!
        }
        set{
            _verticalSensitivity = newValue
            userDefaults.setValue(_verticalSensitivity, forKeyPath: StoredSettings.VERTICAL_SENSITIVITY_KEY)
        }
    }
    
    var shareSensitivity: Bool {
        get {
            if _shareSensitivity == nil {
                if userDefaults.object(forKey: StoredSettings.SHARE_SENSITIVITY_KEY) != nil {
                    _shareSensitivity = userDefaults.bool(forKey: StoredSettings.SHARE_SENSITIVITY_KEY)
                } else {
                    _shareSensitivity = defaultSettings.shareSensitivity
                    userDefaults.setValue(
                        defaultSettings.shareSensitivity,
                        forKeyPath: StoredSettings.SHARE_SENSITIVITY_KEY)
                }
            }
            return _shareSensitivity!
        }
        set{
            _shareSensitivity = newValue
            userDefaults.setValue(_shareSensitivity, forKeyPath: StoredSettings.SHARE_SENSITIVITY_KEY)
        }
    }
    
    var blinkSensitivity: CFTimeInterval {
        get {
            if _blinkSensitivity == nil {
                if userDefaults.object(forKey: StoredSettings.BLINKS_SENSITIVITY_KEY) != nil {
                    _blinkSensitivity = userDefaults.double(forKey: StoredSettings.BLINKS_SENSITIVITY_KEY)
                } else {
                    _blinkSensitivity = defaultSettings.blinkSensitivity
                    userDefaults.setValue(
                        defaultSettings.blinkSensitivity,
                        forKeyPath: StoredSettings.BLINKS_SENSITIVITY_KEY)
                }
            }
            return _blinkSensitivity!
        }
        set {
            _blinkSensitivity = newValue
            userDefaults.setValue(_blinkSensitivity, forKeyPath: StoredSettings.BLINKS_SENSITIVITY_KEY)
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
                if userDefaults.object(forKey: StoredSettings.DWELL_TIME_KEY) != nil {
                    _dwellTime = userDefaults.double(forKey: StoredSettings.DWELL_TIME_KEY)
                } else {
                    _dwellTime = defaultSettings.dwellTime
                    userDefaults.setValue(
                        defaultSettings.dwellTime,
                        forKeyPath: StoredSettings.DWELL_TIME_KEY)
                }
            }
            return _dwellTime!
        }
        set {
            _dwellTime = newValue
            userDefaults.setValue(_dwellTime, forKeyPath: StoredSettings.DWELL_TIME_KEY)
        }
    }
    
    var headMovementCorrection: HeadMovementCorrection {
        get {
            if _headMovementCorrection == nil {
                let settingString = userDefaults.string(
                    forKey: StoredSettings.HEAD_MOVEMENT_CORRECTION_KEY)
                if let option = HeadMovementCorrection.Option(rawValue: settingString ?? "") {
                    _headMovementCorrection = HeadMovementCorrection(option)
                }
                else {
                    _headMovementCorrection = defaultSettings.headMovementCorrection
                    userDefaults.setValue(
                        defaultSettings.headMovementCorrection.option.rawValue,
                        forKeyPath: StoredSettings.HEAD_MOVEMENT_CORRECTION_KEY)
                }
            }
            
            return _headMovementCorrection!
        }
        set {
            _headMovementCorrection = newValue
            userDefaults.setValue(_headMovementCorrection?.option.rawValue ?? nil,
                                  forKeyPath: StoredSettings.HEAD_MOVEMENT_CORRECTION_KEY)
        }
    }
}
