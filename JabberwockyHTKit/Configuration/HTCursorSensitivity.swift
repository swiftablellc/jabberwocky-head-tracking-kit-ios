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

import UIKit

@objc public class HTCursorSensitivity: NSObject {

    //MARK: Singleton Initialization
    @objc public private(set) static var shared: HTCursorSensitivity = HTCursorSensitivity()

    //MARK: Cursor Sensitivity Options
    @objc public var x: Float {
        get {
            return HeadTracking.shared.settings.horizontalSensitivity
        }
        set {
            self.shareSensitivity ? self.updateHorizontalAndVertical(newValue) : self.updateHorizontal(newValue)
        }
    }
    
    @objc public var y: Float {
        get{
            return HeadTracking.shared.settings.verticalSensitivity
        }
        set {
            self.shareSensitivity ? self.updateHorizontalAndVertical(newValue) : self.updateVertical(newValue)
        }
    }
    
    @objc public var average: Float {
        return (x + y) / 2
    }
    
    @objc public var shareSensitivity: Bool {
        get {
            return HeadTracking.shared.settings.shareSensitivity
        }
        set {
            HeadTracking.ifConfigured { headTracking in
                headTracking.settings.shareSensitivity = newValue
            }
        }
    }

    //MARK: Internal
    override private init() { }
    
    private func updateHorizontal(_ newValue: Float) {
        if x == newValue { return }
        
        HeadTracking.ifConfigured { headTracking in
            headTracking.settings.horizontalSensitivity = newValue
            //Since changing sensitivity screws with the cursor, just recalibrate
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .htInitiateRecalibrationCountdownNotification, object: nil)
            }
        }
        
    }
    
    private func updateVertical(_ newValue: Float) {
        if y == newValue { return }
        
        HeadTracking.ifConfigured { headTracking in
            headTracking.settings.verticalSensitivity = newValue
            //Since changing sensitivity screws with the cursor, just recalibrate
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .htInitiateRecalibrationCountdownNotification, object: nil)
            }
        }
    }
    
    private func updateHorizontalAndVertical(_ newValue: Float) {
        if x == newValue && y == newValue { return }
        
        HeadTracking.ifConfigured { headTracking in
            headTracking.settings.horizontalSensitivity = newValue
            headTracking.settings.verticalSensitivity = newValue
            //Since changing sensitivity screws with the cursor, just recalibrate
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .htInitiateRecalibrationCountdownNotification, object: nil)
            }
        }
    }
}
