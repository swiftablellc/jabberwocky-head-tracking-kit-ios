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

import JabberwockyHTKitEngine
import UIKit

@objc public class CursorDwellClickFeature: NSObject, HTFeature {
    
    // MARK: Singleton Initialization
    @objc public private(set) static var shared: CursorDwellClickFeature?

    override private init() { }

    @objc public static func configure() -> HTFeature {
        if CursorDwellClickFeature.shared == nil {
            CursorDwellClickFeature.shared = CursorDwellClickFeature()
        }
        return CursorDwellClickFeature.shared!
    }

    // MARK: HTFeature protocol
    @objc public private(set) var enabled = false

    @objc public func enable() {
        if !enabled {
            enabled = true
            NotificationCenter.default.addObserver(
                self, selector: #selector(self.onFocusNotification(_:)),
                name: .htOnCursorFocusUpdateNotification, object: nil)
        }
    }

    @objc public func disable() {
        if enabled {
            enabled = false
            NotificationCenter.default.removeObserver(self, name: .htOnCursorFocusUpdateNotification, object: nil)
        }
    }

    // MARK: Internal
    
    @objc func onFocusNotification(_ notification: NSNotification)  {
        guard let focusContext = notification.userInfo?[NSNotification.htFocusContextKey]
            as? HTFocusContext else {
            return
        }
        
        guard HTCursor.shared.active else { return }

        guard HeadTracking.shared.settings.clickGesture == ClickGesture.Dwell else { return }

        guard focusContext.focusedElement.htIgnoresCursorMode() ||
           HTCursor.shared.actualCursorMode.isClickMode else { return }

        if #available(iOS 12.0, *) {
            guard focusContext.focusedElement.htIgnoresScrollSpeed() ||
               !CursorScrollFeature.isScrollingFast else { return }
        }
        
        // A fully focused element indicates that dwell click should execute.
        guard focusContext.focusedElement.htFocusLevel >= 1.0 else { return }

        // We must set the focus level to 0 after a dwell click to restart the charge!
        focusContext.focusedElement.htFocusLevel = 0.0
        focusContext.focusedElement.htInitiateAction(focusContext.screenPointInElement)

        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .htOnCursorClickNotification, object: nil,
                userInfo: [NSNotification.htFocusContextKey: focusContext])
        }
    }
}
