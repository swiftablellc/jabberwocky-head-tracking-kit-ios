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

import JabberwockyHTKitCore
import UIKit

@objc public class CursorBlinkClickFeature: NSObject, HTFeature {
    
    // MARK: Singleton Initialization
    @objc public private(set) static var shared: CursorBlinkClickFeature?

    override private init() { }

    @objc public static func configure() -> HTFeature {
        if CursorBlinkClickFeature.shared == nil {
            CursorBlinkClickFeature.shared = CursorBlinkClickFeature()
        }
        return CursorBlinkClickFeature.shared!
    }

    // MARK: HTFeature protocol
    @objc public private(set) var enabled = false

    @objc public func enable() {
        enabled = true
        NotificationCenter.default.addObserver(
                self, selector: #selector(self.onBlinkNotification(_:)),
                name: .htOnBlinkNotification, object: nil)
        NotificationCenter.default.addObserver(
                self, selector: #selector(self.onFocusNotification(_:)),
                name: .htOnCursorFocusUpdateNotification, object: nil)
    }

    @objc public func disable() {
        enabled = false
        NotificationCenter.default.removeObserver(self, name: .htOnBlinkNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .htOnCursorFocusUpdateNotification, object: nil)
    }

    // MARK: Internal
    private var _lastFocusContext: HTFocusContext? = nil
    private var _screenPointInElement: CGPoint? = nil
    
    @objc func onFocusNotification(_ notification: NSNotification) {
        guard let focusContext = notification.userInfo?[NSNotification.htFocusContextKey]
            as? HTFocusContext else {
            _lastFocusContext = nil
            return
        }
        _lastFocusContext = focusContext
    }
    
    @objc func onBlinkNotification(_ notification: NSNotification) {
        guard let blinkContext = notification.userInfo?[NSNotification.htBlinkContextKey]
            as? HTBlinkContext else { return }
        
        guard let focusContext = _lastFocusContext else { return }
        
        guard HTCursor.shared.active else { return }
        
        guard HeadTracking.shared.settings.clickGesture == .Blink else { return }

       
        guard focusContext.focusedElement.htIgnoresCursorMode() ||
            HTCursor.shared.actualCursorMode.isClickMode else { return }
        
        guard focusContext.focusedElement.htIgnoresScrollSpeed() ||
            !CursorScrollFeature.isScrollingFast else { return }
        
        guard blinkContext.blinkDuration >= HTBlinkSensitivity.shared.durationSeconds else {
            focusContext.focusedElement.htHandleTooShortClick()
            return
        }

        focusContext.focusedElement.htInitiateAction(focusContext.screenPointInElement)
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .htOnCursorClickNotification, object: nil,
                userInfo: [NSNotification.htFocusContextKey: focusContext])
        }
    }
}
