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

@objc public class HTBlinkSensitivity: NSObject {
    
    //MARK: Singleton Initialization
    @objc public private(set) static var shared: HTBlinkSensitivity = HTBlinkSensitivity()
    
    //MARK: Blink Sensitivity Options
    @objc public var durationSeconds: CFTimeInterval {
        get {
            return HeadTracking.shared.settings.blinkSensitivity
        }
        set {
            if durationSeconds == newValue { return }
            HeadTracking.ifConfigured { headTracking in
                headTracking.settings.blinkSensitivity = newValue
            }
        }
    }

    //MARK: Internal
    override private init() { }
}
