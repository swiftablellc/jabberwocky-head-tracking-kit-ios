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

@objc public class CursorDrawFeature: NSObject, HTFeature {

    // MARK: Singleton Initialization
    @objc public private(set) static var shared: CursorDrawFeature?

    override private init() { }

    @objc public static func configure(withFeatureEnabled enabled: Bool = true) -> HTFeature {
        if CursorDrawFeature.shared == nil {
            CursorDrawFeature.shared = CursorDrawFeature()
            if enabled {
                CursorDrawFeature.shared?.enable()
            }
        }
        return CursorDrawFeature.shared!
    }

    // MARK: HeadTrackingFeature protocol
    @objc public private(set) var enabled = false

    @objc public func enable() {
        enabled = true
        HTWindows.shared.enable(for: self, of: CursorDrawWindow.self)
    }

    @objc public func disable() {
        enabled = false
        HTWindows.shared.disable(for: self)
    }

    // MARK: Internal
    private var _cursorDrawWindow: CursorDrawWindow?
    @objc public static var cursorDrawWindow: UIWindow? {
        guard let singleton = CursorDrawFeature.shared else {
            return nil
        }
        
        return singleton._cursorDrawWindow
    }

}
