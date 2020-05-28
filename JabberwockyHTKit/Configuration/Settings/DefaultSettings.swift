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

@objc public class DefaultSettings: NSObject, HTSettings {
    
    public static let shared = DefaultSettings()
    
    // MARK: Default Option Specifications

    /*
     Custom Options Specifications should be added to this default list. Although you can reuse
     this as storage for multiple application settings, it is not recommended unless they are
     Head Tracking specific.
     */
    public var optionSpecifications: [String: HTSettingsOptionSpec] = [
        BlinkSensitivityOption.shared.key: BlinkSensitivityOption.shared,
        ClickGestureOption.shared.key: ClickGestureOption.shared,
        CursorGraphicsModeOption.shared.key: CursorGraphicsModeOption.shared,
        CursorStickinessOption.shared.key: CursorStickinessOption.shared,
        DisabledByUserOption.shared.key: DisabledByUserOption.shared,
        DwellTimeOption.shared.key: DwellTimeOption.shared,
        HorizontalSpeedOption.shared.key: HorizontalSpeedOption.shared,
        MinimumElementSizeOption.shared.key: MinimumElementSizeOption.shared,
        ShareSpeedOption.shared.key: ShareSpeedOption.shared,
        VerticalSpeedOption.shared.key: VerticalSpeedOption.shared
    ]
    
    // MARK: Required Methods by HTKitCore
    public var cursorStickiness: CursorStickiness {
        get { getTypedObject(CursorStickinessOption.shared) }
        set { setObject(CursorStickinessOption.shared.key, newValue) }
    }
    
    public var horizontalSpeed: Float {
        get { getTypedObject(HorizontalSpeedOption.shared) }
        set { setObject(HorizontalSpeedOption.shared.key, newValue) }
    }
    
    public var verticalSpeed: Float {
        get { getTypedObject(VerticalSpeedOption.shared) }
        set { setObject(VerticalSpeedOption.shared.key, newValue) }
    }
    
    // MARK: Convenience Method Implementations
    public var blinkSensitivity: CFTimeInterval {
        get { getTypedObject(BlinkSensitivityOption.shared) }
        set { setObject(BlinkSensitivityOption.shared.key, newValue) }
    }

    public var clickGesture: ClickGesture {
        get { getTypedObject(ClickGestureOption.shared) }
        set { setObject(ClickGestureOption.shared.key, newValue) }
    }

    public var cursorGraphicsMode: CursorGraphicsMode {
        get { getTypedObject(CursorGraphicsModeOption.shared) }
        set { setObject(CursorGraphicsModeOption.shared.key, newValue) }
    }

    public var disabledByUser: Bool {
        get { getTypedObject(DisabledByUserOption.shared) }
        set { setObject(DisabledByUserOption.shared.key, newValue) }
    }

    public var dwellTime: CFTimeInterval {
        get { getTypedObject(DwellTimeOption.shared) }
        set { setObject(DwellTimeOption.shared.key, newValue) }
    }

    public var minimumElementSize: CGFloat {
        get { getTypedObject(MinimumElementSizeOption.shared) }
        set { setObject(MinimumElementSizeOption.shared.key, newValue) }
    }

    public var shareSpeed: Bool {
        get { getTypedObject(ShareSpeedOption.shared) }
        set { setObject(ShareSpeedOption.shared.key, newValue) }
    }
    
    // MARK: Generic Getters/Setters
    
    public func getDefaultObject(_ key: String) -> Any? {
        guard let optionSpec = optionSpecifications[key] else { return nil }
        return optionSpec.defaultObjectValue
    }
    
    public func getDefaultOption(_ key: String) -> Any? {
        guard let optionSpec = optionSpecifications[key] else { return nil }
        return optionSpec.toOptionValue(objectValue: optionSpec.defaultObjectValue)
    }
    
    public func getObject(_ key: String) -> Any? {
        return getDefaultObject(key)
    }
    
    public func getOption(_ key: String) -> Any? {
        return getDefaultOption(key)
    }
    
    public func getObjects() -> [String : Any] {
        var result: [String: Any] = [:]
        for optionSpecificationElement in optionSpecifications {
            result[optionSpecificationElement.key] = getObject(optionSpecificationElement.key)
        }
        return result
    }
    
    public func getOptions() -> [String : Any] {
        var result: [String: Any] = [:]
        for optionSpecificationElement in optionSpecifications {
            result[optionSpecificationElement.key] = getOption(optionSpecificationElement.key)
        }
        return result
    }
    
    @discardableResult
    public func setObject(_ key: String, _ objectValue: Any) -> Bool { return false }
    
    @discardableResult
    public func setOption(_ key: String, _ optionValue: Any) -> Bool { return false }
    
}
